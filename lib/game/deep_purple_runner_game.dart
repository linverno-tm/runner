import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:endless_runner/game/components/gradient_background_component.dart';
import 'package:endless_runner/game/components/obstacle_component.dart';
import 'package:endless_runner/game/components/player_component.dart';
import 'package:endless_runner/game/game_config.dart';
import 'package:endless_runner/services/high_score_store.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/overlays/game_over_overlay.dart';
import 'package:endless_runner/ui/overlays/pause_overlay.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/foundation.dart';

/// The endless runner.
///
/// Responsibilities are deliberately narrow: own the run state (score, speed,
/// game-over), spawn and cull obstacles, and expose the palette that both the
/// components and the Flutter overlays render from. Physics lives in
/// [PlayerComponent]; tuning lives in [GameConfig].
class DeepPurpleRunnerGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  DeepPurpleRunnerGame({
    required bool isDarkMode,
    HighScoreStore? highScoreStore,
    math.Random? random,
  }) : _isDarkMode = isDarkMode,
       _highScoreStore = highScoreStore ?? const SharedPreferencesHighScoreStore(),
       _random = random ?? math.Random();

  final HighScoreStore _highScoreStore;
  final math.Random _random;

  /// Current run score. Listened to by the HUD and the game-over card.
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

  /// Best score seen on this device, restored on load.
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);

  late PlayerComponent player;
  late GradientBackgroundComponent background;

  bool _isDarkMode;
  bool isGameOver = false;
  bool isPaused = false;
  double worldSpeed = GameConfig.initialWorldSpeed;
  double groundY = 0;

  double _scoreAccumulator = 0;
  double _spawnTimer = 0;

  AppPalette get palette => AppPalette.fromMode(isDarkMode: _isDarkMode);

  bool get isDarkMode => _isDarkMode;

  /// Where the player sits horizontally, derived from the viewport.
  double get playerX => size.x * GameConfig.playerXFactor;

  @override
  Future<void> onLoad() async {
    background = GradientBackgroundComponent();
    add(background);

    player = PlayerComponent();
    add(player);

    highScoreNotifier.value = await _highScoreStore.read();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    groundY = size.y * (1 - GameConfig.groundHeightFactor);
    final unit = math.min(size.x, size.y);

    if (isMounted && player.isMounted) {
      player.reposition(
        x: size.x * GameConfig.playerXFactor,
        groundY: groundY,
        size: Vector2(
          unit * GameConfig.playerWidthFactor,
          unit * GameConfig.playerHeightFactor,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused || !isLoaded) {
      return;
    }

    _spawnTimer += dt;
    _scoreAccumulator += dt;

    if (_spawnTimer >= _nextSpawnDelay()) {
      _spawnTimer = 0;
      _spawnObstacle();
    }

    if (_scoreAccumulator >= GameConfig.secondsPerPoint) {
      _scoreAccumulator = 0;
      scoreNotifier.value += 1;
    }

    worldSpeed = (worldSpeed + dt * GameConfig.worldAcceleration).clamp(
      GameConfig.initialWorldSpeed,
      GameConfig.maxWorldSpeed,
    );
  }

  void setThemeMode({required bool isDarkMode}) {
    _isDarkMode = isDarkMode;
  }

  /// Spawn cadence tightens as the world speeds up, with jitter on top.
  double _nextSpawnDelay() {
    final speedProgress =
        ((worldSpeed - GameConfig.initialWorldSpeed) /
                (GameConfig.maxWorldSpeed - GameConfig.initialWorldSpeed))
            .clamp(0.0, 1.0);

    return (GameConfig.baseSpawnDelay -
            speedProgress * GameConfig.spawnDelaySpeedBonus) +
        _random.nextDouble() * GameConfig.spawnDelayJitter;
  }

  void _spawnObstacle() {
    final unit = math.min(size.x, size.y);
    final obstacleSize = Vector2(
      unit *
          (GameConfig.obstacleMinWidthFactor +
              _random.nextDouble() * GameConfig.obstacleWidthJitter),
      unit *
          (GameConfig.obstacleMinHeightFactor +
              _random.nextDouble() * GameConfig.obstacleHeightJitter),
    );

    add(
      ObstacleComponent(size: obstacleSize, random: _random)
        ..position = Vector2(size.x + obstacleSize.x, groundY - obstacleSize.y),
    );
  }

  /// Ends the run: burst, freeze, record the score, show the card.
  void onPlayerHitObstacle(Vector2 impactPoint) {
    if (isGameOver) {
      return;
    }

    _spawnImpactParticles(impactPoint);
    isGameOver = true;
    pauseEngine();
    unawaited(_recordHighScore());
    overlays.add(GameOverOverlay.id);
  }

  Future<void> _recordHighScore() async {
    if (scoreNotifier.value <= highScoreNotifier.value) {
      return;
    }
    highScoreNotifier.value = scoreNotifier.value;
    await _highScoreStore.write(highScoreNotifier.value);
  }

  void _spawnImpactParticles(Vector2 impactPoint) {
    add(
      ParticleSystemComponent(
        position: impactPoint,
        particle: Particle.generate(
          count: GameConfig.impactParticleCount,
          lifespan: GameConfig.impactParticleLifespan,
          generator: (index) {
            final angle = _random.nextDouble() * math.pi * 2;
            final speed = 120 + _random.nextDouble() * 230;
            return AcceleratedParticle(
              // Bias the spread upward so the burst reads as an impact
              // rather than an explosion centred on the player.
              speed: Vector2(math.cos(angle), math.sin(angle) - 0.7) * speed,
              acceleration: Vector2(0, 720),
              child: CircleParticle(
                radius: 1.6 + _random.nextDouble() * 2.2,
                paint: Paint()
                  ..color = palette.neon.withValues(alpha: 0.85)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Freezes the run and shows the pause card.
  void pause() {
    if (isGameOver || isPaused) {
      return;
    }
    isPaused = true;
    pauseEngine();
    overlays.add(PauseOverlay.id);
  }

  /// Resumes a paused run.
  void resume() {
    if (!isPaused) {
      return;
    }
    isPaused = false;
    overlays.remove(PauseOverlay.id);
    resumeEngine();
  }

  /// Clears the world and starts a fresh run.
  void restart() {
    overlays.remove(GameOverOverlay.id);
    overlays.remove(PauseOverlay.id);

    isGameOver = false;
    isPaused = false;
    worldSpeed = GameConfig.initialWorldSpeed;
    _spawnTimer = 0;
    _scoreAccumulator = 0;
    scoreNotifier.value = 0;

    for (final obstacle in children.whereType<ObstacleComponent>().toList()) {
      obstacle.removeFromParent();
    }

    player.reset(groundY: groundY, x: playerX);
    resumeEngine();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || isPaused) {
      return;
    }
    player.jump();
  }

  @override
  void onRemove() {
    scoreNotifier.dispose();
    highScoreNotifier.dispose();
    super.onRemove();
  }
}
