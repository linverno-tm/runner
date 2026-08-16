import 'dart:math' as math;
import 'dart:ui';

import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/animation.dart';

/// A single scrolling obstacle.
///
/// Each instance carries a random phase so obstacles drift in and out of sync
/// with one another; the resulting spacing is harder to memorise than a fixed
/// cadence would be. Obstacles remove themselves once off-screen.
class ObstacleComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<DeepPurpleRunnerGame> {
  ObstacleComponent({required Vector2 size, math.Random? random})
    : _phase = (random ?? math.Random()).nextDouble() * math.pi * 2 {
    this.size = size;
  }

  /// Speed oscillation bounds, as a multiplier of the world speed.
  static const double _minSpeedFactor = 0.88;
  static const double _maxSpeedFactor = 1.14;
  static const double _oscillationRate = 2.2;

  /// How far past the left edge an obstacle travels before being culled.
  static const double _cullMargin = 12;

  final double _phase;
  double _motionClock = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    canvas.drawRRect(
      rounded,
      Paint()
        ..color = game.palette.neon.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      rounded,
      Paint()..color = game.palette.neon.withValues(alpha: 0.95),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _motionClock += dt;
    final wave = (math.sin(_motionClock * _oscillationRate + _phase) + 1) / 2;
    final eased = Curves.easeInOut.transform(wave);
    final speedFactor =
        lerpDouble(_minSpeedFactor, _maxSpeedFactor, eased) ?? 1.0;

    x -= game.worldSpeed * speedFactor * dt;

    if (x + size.x < -_cullMargin) {
      removeFromParent();
    }
  }
}
