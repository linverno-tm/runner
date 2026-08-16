import 'dart:ui';

import 'package:endless_runner/game/components/obstacle_component.dart';
import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/game/game_config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// The player capsule.
///
/// Owns its own vertical physics: gravity integration, a single-jump guard,
/// and a clamped fall speed. Horizontal movement is an illusion produced by
/// [ObstacleComponent] scrolling towards the player.
class PlayerComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<DeepPurpleRunnerGame> {
  PlayerComponent({
    this.gravity = GameConfig.gravity,
    this.jumpVelocity = GameConfig.jumpVelocity,
    this.fallGravityMultiplier = GameConfig.fallGravityMultiplier,
    this.maxFallSpeed = GameConfig.maxFallSpeed,
  });

  final double gravity;
  final double jumpVelocity;
  final double fallGravityMultiplier;
  final double maxFallSpeed;

  double _velocityY = 0;
  bool _isOnGround = true;

  /// Whether the player is currently standing on the floor.
  bool get isOnGround => _isOnGround;

  /// Current vertical velocity. Negative while rising.
  double get velocityY => _velocityY;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Two passes: a blurred halo, then the solid body on top of it.
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = game.palette.neon.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(rounded, Paint()..color = game.palette.neon);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Falling uses a heavier gravity than rising so the jump arc reads as
    // responsive instead of floaty.
    final effectiveGravity = _velocityY > 0
        ? gravity * fallGravityMultiplier
        : gravity;

    _velocityY += effectiveGravity * dt;
    _velocityY = _velocityY.clamp(jumpVelocity * 1.2, maxFallSpeed);
    y += _velocityY * dt;

    final floor = game.groundY - size.y;
    if (y >= floor) {
      y = floor;
      _velocityY = 0;
      _isOnGround = true;
    }
  }

  /// Re-anchors the player after a viewport resize.
  void reposition({
    required double x,
    required double groundY,
    required Vector2 size,
  }) {
    this.size = size;
    position = Vector2(x, groundY - size.y);
  }

  /// Applies the jump impulse. Ignored while airborne - no double jump.
  void jump() {
    if (!_isOnGround) {
      return;
    }
    _isOnGround = false;
    _velocityY = jumpVelocity;
  }

  /// Returns the player to its starting pose for a new run.
  void reset({required double groundY, required double x}) {
    _velocityY = 0;
    _isOnGround = true;
    position = Vector2(x, groundY - size.y);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ObstacleComponent) {
      game.onPlayerHitObstacle(position + size / 2);
    }
  }
}
