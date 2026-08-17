import 'dart:math' as math;

import 'package:endless_runner/game/components/obstacle_component.dart';
import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/game/game_config.dart';
import 'package:endless_runner/services/high_score_store.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/overlays/game_over_overlay.dart';
import 'package:endless_runner/ui/overlays/hud_overlay.dart';
import 'package:endless_runner/ui/overlays/pause_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts the game in a fixed viewport and waits for `onLoad` and the first
/// `onGameResize` pass.
///
/// Overlays are registered but none is active: `animate_do` schedules a timer
/// on mount, which would still be pending at teardown and fail the test.
Future<DeepPurpleRunnerGame> _pumpGame(
  WidgetTester tester, {
  HighScoreStore? highScoreStore,
  math.Random? random,
}) async {
  final game = DeepPurpleRunnerGame(
    isDarkMode: true,
    highScoreStore: highScoreStore ?? InMemoryHighScoreStore(),
    // Seeded so obstacle spawn timings are reproducible.
    random: random ?? math.Random(1234),
  );

  await tester.pumpWidget(
    CupertinoApp(
      home: SizedBox(
        width: 800,
        height: 600,
        child: GameWidget<DeepPurpleRunnerGame>(
          game: game,
          overlayBuilderMap: {
            HudOverlay.id: (context, game) => HudOverlay(
              game: game,
              isDarkMode: true,
              onThemeChanged: (_) {},
            ),
            PauseOverlay.id: (context, game) =>
                PauseOverlay(game: game, isDarkMode: true),
            GameOverOverlay.id: (context, game) =>
                GameOverOverlay(game: game, isDarkMode: true),
          },
          initialActiveOverlays: const <String>[],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  return game;
}

/// Flushes the entrance animation `animate_do` starts when an overlay mounts.
///
/// `pumpAndSettle` is not enough here: the collision pauses the Flame engine,
/// so no further frames are scheduled and the pending timer would still be
/// alive at teardown.
Future<void> _settleOverlays(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Advances the loop by [frames] at a fixed 60fps step.
///
/// Steps the game state only. Components queued with `add` are attached by
/// [_advanceWorld], which runs the full tree.
void _advance(DeepPurpleRunnerGame game, int frames) {
  for (var i = 0; i < frames; i++) {
    game.update(1 / 60);
  }
}

/// Advances the loop and lets queued components finish attaching.
///
/// `add` completes asynchronously, so a purely synchronous loop never gives
/// the pending `onLoad` futures a chance to resolve and spawned obstacles
/// would never appear in `children`. Pumping yields to the event loop.
Future<void> _advanceWorld(
  WidgetTester tester,
  DeepPurpleRunnerGame game,
  int frames,
) async {
  for (var i = 0; i < frames; i++) {
    game.update(1 / 60);
    if (i % 10 == 9) {
      await tester.pump();
    }
  }
  await tester.pump();
}

void main() {
  group('layout', () {
    testWidgets('derives the ground line from the viewport height', (
      tester,
    ) async {
      final game = await _pumpGame(tester);

      expect(
        game.groundY,
        closeTo(600 * (1 - GameConfig.groundHeightFactor), 0.001),
      );
      expect(game.player.isMounted, isTrue);
      expect(game.isGameOver, isFalse);
      expect(game.isPaused, isFalse);
    });

    testWidgets('places the player on the ground at the configured x', (
      tester,
    ) async {
      final game = await _pumpGame(tester);

      expect(game.player.y, closeTo(game.groundY - game.player.size.y, 0.001));
      expect(game.player.x, closeTo(800 * GameConfig.playerXFactor, 0.001));
      expect(game.player.isOnGround, isTrue);
    });
  });

  group('jumping', () {
    testWidgets('a tap lifts the player off the ground', (tester) async {
      final game = await _pumpGame(tester);
      final restingY = game.player.y;

      game.player.jump();
      _advance(game, 1);

      expect(game.player.y, lessThan(restingY));
      expect(game.player.isOnGround, isFalse);
      expect(game.player.velocityY, lessThan(0));
    });

    testWidgets('a second jump while airborne is ignored', (tester) async {
      final game = await _pumpGame(tester);

      game.player.jump();
      _advance(game, 1);
      final velocityAfterFirstJump = game.player.velocityY;

      game.player.jump();

      // The impulse must not be re-applied, so velocity keeps decaying under
      // gravity rather than snapping back to jumpVelocity.
      expect(game.player.velocityY, velocityAfterFirstJump);
      expect(game.player.velocityY, greaterThan(GameConfig.jumpVelocity));
    });

    testWidgets('the player lands back on the ground', (tester) async {
      final game = await _pumpGame(tester);
      final restingY = game.player.y;

      game.player.jump();
      _advance(game, 240);

      expect(game.player.y, closeTo(restingY, 0.001));
      expect(game.player.isOnGround, isTrue);
      expect(game.player.velocityY, 0);
    });
  });

  group('run progression', () {
    testWidgets('score advances while the run is live', (tester) async {
      final game = await _pumpGame(tester);

      expect(game.scoreNotifier.value, 0);
      _advance(game, 30);

      expect(game.scoreNotifier.value, greaterThan(0));
    });

    testWidgets('world speed accelerates but stays clamped', (tester) async {
      final game = await _pumpGame(tester);

      expect(game.worldSpeed, GameConfig.initialWorldSpeed);
      _advance(game, 6000);

      expect(game.worldSpeed, GameConfig.maxWorldSpeed);
    });

    testWidgets('obstacles are spawned as time passes', (tester) async {
      final game = await _pumpGame(tester);

      // ~2.2s: past the longest possible first spawn delay (1.90s) but before
      // the leading obstacle can reach the player (~2.85s at the slowest).
      await _advanceWorld(tester, game, 130);

      expect(game.children.whereType<ObstacleComponent>(), isNotEmpty);
      expect(game.isGameOver, isFalse);
    });
  });

  group('pause', () {
    testWidgets('pausing freezes the score and shows the card', (tester) async {
      final game = await _pumpGame(tester);

      _advance(game, 30);
      final scoreBeforePause = game.scoreNotifier.value;

      game.pause();
      _advance(game, 120);

      expect(game.isPaused, isTrue);
      expect(game.overlays.isActive(PauseOverlay.id), isTrue);
      expect(game.scoreNotifier.value, scoreBeforePause);

      game.resume();
      _advance(game, 30);

      expect(game.isPaused, isFalse);
      expect(game.overlays.isActive(PauseOverlay.id), isFalse);
      expect(game.scoreNotifier.value, greaterThan(scoreBeforePause));

      game.pauseEngine();
      await _settleOverlays(tester);
    });

    testWidgets('pausing after game over is a no-op', (tester) async {
      final game = await _pumpGame(tester);

      game.onPlayerHitObstacle(game.player.position.clone());
      game.pause();

      expect(game.isPaused, isFalse);
      expect(game.overlays.isActive(PauseOverlay.id), isFalse);

      await _settleOverlays(tester);
    });
  });

  group('game over and restart', () {
    testWidgets('a collision ends the run and shows the card', (tester) async {
      final game = await _pumpGame(tester);

      _advance(game, 30);
      game.onPlayerHitObstacle(game.player.position.clone());
      await _settleOverlays(tester);

      expect(game.isGameOver, isTrue);
      expect(game.overlays.isActive(GameOverOverlay.id), isTrue);
    });

    testWidgets('restart clears score, speed, obstacles and overlays', (
      tester,
    ) async {
      final game = await _pumpGame(tester);

      await _advanceWorld(tester, game, 130);
      expect(game.scoreNotifier.value, greaterThan(0));
      expect(game.children.whereType<ObstacleComponent>(), isNotEmpty);

      game.player.jump();
      game.onPlayerHitObstacle(game.player.position.clone());
      await _settleOverlays(tester);

      game.restart();

      expect(game.isGameOver, isFalse);
      expect(game.scoreNotifier.value, 0);
      expect(game.worldSpeed, GameConfig.initialWorldSpeed);
      expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
      expect(game.player.y, closeTo(game.groundY - game.player.size.y, 0.001));
      expect(game.player.x, closeTo(game.playerX, 0.001));
      expect(game.player.isOnGround, isTrue);

      // Removal is queued like any other lifecycle event, so it lands on the
      // next tick rather than synchronously inside restart().
      await tester.pump();
      expect(game.children.whereType<ObstacleComponent>(), isEmpty);

      game.pauseEngine();
      await _settleOverlays(tester);
    });

    testWidgets('a second collision does not re-trigger game over', (
      tester,
    ) async {
      final game = await _pumpGame(tester);

      game.onPlayerHitObstacle(game.player.position.clone());
      final childrenAfterFirst = game.children.length;

      game.onPlayerHitObstacle(game.player.position.clone());

      expect(game.children.length, childrenAfterFirst);
      await _settleOverlays(tester);
    });
  });

  group('high score', () {
    testWidgets('is restored from the store on load', (tester) async {
      final game = await _pumpGame(
        tester,
        highScoreStore: InMemoryHighScoreStore(120),
      );

      expect(game.highScoreNotifier.value, 120);
    });

    testWidgets('a better run is persisted', (tester) async {
      final store = InMemoryHighScoreStore(2);
      final game = await _pumpGame(tester, highScoreStore: store);

      _advance(game, 120);
      final score = game.scoreNotifier.value;
      expect(score, greaterThan(2));

      game.onPlayerHitObstacle(game.player.position.clone());
      await _settleOverlays(tester);

      expect(game.highScoreNotifier.value, score);
      expect(await store.read(), score);
    });

    testWidgets('a worse run leaves the record alone', (tester) async {
      final store = InMemoryHighScoreStore(9999);
      final game = await _pumpGame(tester, highScoreStore: store);

      _advance(game, 30);
      game.onPlayerHitObstacle(game.player.position.clone());
      await _settleOverlays(tester);

      expect(game.highScoreNotifier.value, 9999);
      expect(await store.read(), 9999);
    });
  });

  group('theme', () {
    testWidgets('toggling swaps the palette the components render from', (
      tester,
    ) async {
      final game = await _pumpGame(tester);

      expect(game.palette, AppPalette.neonGlow);
      expect(game.isDarkMode, isTrue);

      game.setThemeMode(isDarkMode: false);

      expect(game.palette, AppPalette.pastel);
      expect(game.isDarkMode, isFalse);
    });
  });
}
