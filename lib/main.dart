import 'dart:math' as math;
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DeepPurpleRunnerApp());
}

class DeepPurpleRunnerApp extends StatefulWidget {
  const DeepPurpleRunnerApp({super.key});

  @override
  State<DeepPurpleRunnerApp> createState() => _DeepPurpleRunnerAppState();
}

class _DeepPurpleRunnerAppState extends State<DeepPurpleRunnerApp> {
  bool _isDarkMode = true;
  late final DeepPurpleRunnerGame _game;

  @override
  void initState() {
    super.initState();
    _game = DeepPurpleRunnerGame(isDarkMode: _isDarkMode);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      _game.setThemeMode(isDarkMode: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.fromMode(isDarkMode: _isDarkMode);

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Deep Purple Runner',
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: palette.primary,
        scaffoldBackgroundColor: palette.backgroundStart,
      ),
      home: CupertinoPageScaffold(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: GameWidget<DeepPurpleRunnerGame>(
                  game: _game,
                  overlayBuilderMap: {
                    HudOverlay.id: (context, game) {
                      return HudOverlay(
                        game: game,
                        isDarkMode: _isDarkMode,
                        onThemeChanged: _toggleTheme,
                      );
                    },
                    GameOverOverlay.id: (context, game) {
                      return GameOverOverlay(
                        game: game,
                        isDarkMode: _isDarkMode,
                      );
                    },
                  },
                  initialActiveOverlays: const [HudOverlay.id],
                ),
              ),
              const _GlassFloorOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPalette {
  const AppPalette({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.primary,
    required this.neon,
    required this.surface,
    required this.text,
  });

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color primary;
  final Color neon;
  final Color surface;
  final Color text;

  static AppPalette fromMode({required bool isDarkMode}) {
    return isDarkMode
        ? const AppPalette(
            backgroundStart: Color(0xFF0F0C29),
            backgroundEnd: Color(0xFF302B63),
            primary: Color(0xFF673AB7),
            neon: Color(0xFFBD00FF),
            surface: Color(0x8021242E),
            text: CupertinoColors.white,
          )
        : const AppPalette(
            backgroundStart: Color(0xFFF5F1FF),
            backgroundEnd: Color(0xFFDDE2F7),
            primary: Color(0xFF7E57C2),
            neon: Color(0xFF9B6DFF),
            surface: Color(0x80FFFFFF),
            text: Color(0xFF1A1A1A),
          );
  }
}

class DeepPurpleRunnerGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  DeepPurpleRunnerGame({required bool isDarkMode})
    : _isDarkMode = isDarkMode,
      scoreNotifier = ValueNotifier<int>(0);

  static const double _gravity = 1520;
  static const double _jumpVelocity = -920;
  static const double _groundHeightFactor = 0.18;
  static const double _initialWorldSpeed = 365;
  static const double _maxWorldSpeed = 540;

  final ValueNotifier<int> scoreNotifier;

  late PlayerComponent player;
  late GradientBackgroundComponent background;

  bool _isDarkMode;
  bool isGameOver = false;
  double worldSpeed = _initialWorldSpeed;
  double groundY = 0;

  final math.Random _random = math.Random();
  double _scoreAccumulator = 0;
  double _spawnTimer = 0;

  AppPalette get palette => AppPalette.fromMode(isDarkMode: _isDarkMode);

  @override
  Future<void> onLoad() async {
    background = GradientBackgroundComponent();
    add(background);

    player = PlayerComponent(
      gravity: _gravity,
      jumpVelocity: _jumpVelocity,
      fallGravityMultiplier: 2.15,
      maxFallSpeed: 1220,
    );
    add(player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    groundY = size.y * (1 - _groundHeightFactor);
    final unit = math.min(size.x, size.y);

    if (isMounted && player.isMounted) {
      player.reposition(
        x: size.x * 0.16,
        groundY: groundY,
        size: Vector2(unit * 0.08, unit * 0.12),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || !isLoaded) return;

    _spawnTimer += dt;
    _scoreAccumulator += dt;

    if (_spawnTimer >= _nextSpawnDelay()) {
      _spawnTimer = 0;
      _spawnObstacle();
    }

    if (_scoreAccumulator >= 0.2) {
      _scoreAccumulator = 0;
      scoreNotifier.value += 1;
    }

    worldSpeed = (worldSpeed + dt * 2.1).clamp(
      _initialWorldSpeed,
      _maxWorldSpeed,
    );
  }

  void setThemeMode({required bool isDarkMode}) {
    _isDarkMode = isDarkMode;
  }

  double _nextSpawnDelay() {
    final speedFactor =
        ((worldSpeed - _initialWorldSpeed) /
                (_maxWorldSpeed - _initialWorldSpeed))
            .clamp(0, 1);
    return (1.25 - speedFactor * 0.26) + _random.nextDouble() * 0.65;
  }

  void _spawnObstacle() {
    final unit = math.min(size.x, size.y);
    final obstacleSize = Vector2(
      unit * (0.055 + _random.nextDouble() * 0.035),
      unit * (0.10 + _random.nextDouble() * 0.05),
    );

    final obstacle = ObstacleComponent(size: obstacleSize);
    obstacle.position = Vector2(
      size.x + obstacleSize.x,
      groundY - obstacleSize.y,
    );
    add(obstacle);
  }

  void onPlayerHitObstacle(Vector2 impactPoint) {
    if (isGameOver) return;

    _spawnImpactParticles(impactPoint);
    isGameOver = true;
    pauseEngine();
    overlays.add(GameOverOverlay.id);
  }

  void _spawnImpactParticles(Vector2 impactPoint) {
    add(
      ParticleSystemComponent(
        position: impactPoint,
        particle: Particle.generate(
          count: 22,
          lifespan: 0.45,
          generator: (index) {
            final angle = _random.nextDouble() * math.pi * 2;
            final speed = 120 + _random.nextDouble() * 230;
            return AcceleratedParticle(
              speed: Vector2(math.cos(angle), math.sin(angle) - 0.7) * speed,
              acceleration: Vector2(0, 720),
              child: CircleParticle(
                radius: 1.6 + _random.nextDouble() * 2.2,
                paint: Paint()
                  ..color = palette.neon.withOpacity(0.85)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void restart() {
    overlays.remove(GameOverOverlay.id);
    isGameOver = false;
    worldSpeed = _initialWorldSpeed;
    _spawnTimer = 0;
    _scoreAccumulator = 0;
    scoreNotifier.value = 0;

    for (final obstacle in children.whereType<ObstacleComponent>().toList()) {
      obstacle.removeFromParent();
    }

    player.reset(groundY: groundY);
    resumeEngine();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isGameOver) {
      player.jump();
    }
  }
}

class GradientBackgroundComponent extends Component
    with HasGameRef<DeepPurpleRunnerGame> {
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [gameRef.palette.backgroundStart, gameRef.palette.backgroundEnd],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }
}

class PlayerComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<DeepPurpleRunnerGame> {
  PlayerComponent({
    required this.gravity,
    required this.jumpVelocity,
    required this.fallGravityMultiplier,
    required this.maxFallSpeed,
  });

  final double gravity;
  final double jumpVelocity;
  final double fallGravityMultiplier;
  final double maxFallSpeed;

  double _velocityY = 0;
  bool _isOnGround = true;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final glowPaint = Paint()
      ..color = gameRef.palette.neon.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final fillPaint = Paint()..color = gameRef.palette.neon;

    canvas.drawRRect(rr, glowPaint);
    canvas.drawRRect(rr, fillPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final effectiveGravity =
        _velocityY > 0 ? gravity * fallGravityMultiplier : gravity;
    _velocityY += effectiveGravity * dt;
    _velocityY = math.max(jumpVelocity * 1.2, math.min(_velocityY, maxFallSpeed));
    y += _velocityY * dt;

    final floor = gameRef.groundY - size.y;
    if (y >= floor) {
      y = floor;
      _velocityY = 0;
      _isOnGround = true;
    }
  }

  void reposition({
    required double x,
    required double groundY,
    required Vector2 size,
  }) {
    this.size = size;
    position = Vector2(x, groundY - size.y);
  }

  void jump() {
    if (!_isOnGround) return;
    _isOnGround = false;
    _velocityY = jumpVelocity;
  }

  void reset({required double groundY}) {
    _velocityY = 0;
    _isOnGround = true;
    y = groundY - size.y;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ObstacleComponent) {
      gameRef.onPlayerHitObstacle(position + size / 2);
    }
  }
}

class ObstacleComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<DeepPurpleRunnerGame> {
  ObstacleComponent({required Vector2 size}) {
    this.size = size;
  }

  double _motionClock = 0;
  final double _phase = math.Random().nextDouble() * math.pi * 2;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final shadowPaint = Paint()
      ..color = gameRef.palette.neon.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final fillPaint = Paint()..color = gameRef.palette.neon.withOpacity(0.95);

    canvas.drawRRect(rr, shadowPaint);
    canvas.drawRRect(rr, fillPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _motionClock += dt;
    final wave = (math.sin(_motionClock * 2.2 + _phase) + 1) / 2;
    final eased = Curves.easeInOut.transform(wave);
    final speedFactor = lerpDouble(0.88, 1.14, eased) ?? 1.0;

    x -= gameRef.worldSpeed * speedFactor * dt;

    if (x + size.x < -12) {
      removeFromParent();
    }
  }
}

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.game,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  static const String id = 'hud';

  final DeepPurpleRunnerGame game;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = game.palette;

    return FadeInDown(
      duration: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CustomModeToggle(
              isDarkMode: isDarkMode,
              palette: palette,
              onChanged: onThemeChanged,
            ),
            const Spacer(),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, child) {
                return _GlassCard(
                  palette: palette,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(score),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 1.2, end: 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GlowText(
                      'SCORE $score',
                      blurRadius: 6,
                      glowColor: palette.neon,
                      style: GoogleFonts.orbitron(
                        color: palette.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.game,
    required this.isDarkMode,
  });

  static const String id = 'game_over';

  final DeepPurpleRunnerGame game;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.fromMode(isDarkMode: isDarkMode);

    return Positioned.fill(
      child: Container(
        color: CupertinoColors.black.withOpacity(0.35),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 260),
            child: _GlassCard(
              palette: palette,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlowText(
                    'GAME OVER',
                    blurRadius: 7,
                    glowColor: palette.neon,
                    style: GoogleFonts.pressStart2p(
                      color: palette.text,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<int>(
                    valueListenable: game.scoreNotifier,
                    builder: (context, score, child) {
                      return Text(
                        'Final score: $score',
                        style: GoogleFonts.orbitron(
                          color: palette.text.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GlowContainer(
                    borderRadius: BorderRadius.circular(12),
                    color: palette.primary,
                    glowColor: palette.neon.withOpacity(0.45),
                    blurRadius: 14,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      onPressed: game.restart,
                      child: Text(
                        'Restart',
                        style: GoogleFonts.orbitron(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomModeToggle extends StatelessWidget {
  const _CustomModeToggle({
    required this.isDarkMode,
    required this.palette,
    required this.onChanged,
  });

  final bool isDarkMode;
  final AppPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      child: _GlassCard(
        palette: palette,
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          width: 160,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [palette.backgroundStart, palette.backgroundEnd]
                  : [const Color(0xFFFDFDFF), const Color(0xFFDDE7FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? palette.neon : palette.primary)
                    .withOpacity(0.45),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOut,
                alignment: isDarkMode
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDarkMode
                        ? palette.neon.withOpacity(0.24)
                        : palette.primary.withOpacity(0.22),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Neon Glow',
                        style: GoogleFonts.orbitron(
                          color: palette.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Pastel',
                        style: GoogleFonts.orbitron(
                          color: palette.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final AppPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GlowContainer(
          borderRadius: BorderRadius.circular(12),
          color: palette.surface,
          glowColor: palette.neon.withOpacity(0.25),
          blurRadius: 10,
          spreadRadius: 0.3,
          padding: padding,
          border: Border.all(color: CupertinoColors.white.withOpacity(0.18)),
          child: child,
        ),
      ),
    );
  }
}

class _GlassFloorOverlay extends StatelessWidget {
  const _GlassFloorOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final floorHeight = constraints.maxHeight * 0.18;

          return Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: floorHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.2),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFBD00FF).withOpacity(0.95),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
