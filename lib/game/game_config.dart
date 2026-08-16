/// Tuning values for the run.
///
/// Keeping these in one place makes the difficulty curve reviewable without
/// reading the game loop, and lets tests assert against named constants
/// instead of magic numbers.
abstract final class GameConfig {
  /// Downward acceleration applied every frame, in logical pixels/s².
  static const double gravity = 1520;

  /// Upward impulse applied on tap. Negative because y grows downward.
  static const double jumpVelocity = -920;

  /// Falling is accelerated so the arc feels snappy rather than floaty.
  static const double fallGravityMultiplier = 2.15;

  /// Terminal velocity, so a long fall stays controllable.
  static const double maxFallSpeed = 1220;

  /// Height of the glass floor as a fraction of the viewport.
  static const double groundHeightFactor = 0.18;

  static const double initialWorldSpeed = 365;
  static const double maxWorldSpeed = 540;

  /// How quickly the world accelerates, in pixels/s per second.
  static const double worldAcceleration = 2.1;

  /// One point is scored per this many seconds survived.
  static const double secondsPerPoint = 0.2;

  /// Player size and horizontal position, relative to the shorter viewport
  /// edge, so the game scales the same way on phones and on the web.
  static const double playerWidthFactor = 0.08;
  static const double playerHeightFactor = 0.12;
  static const double playerXFactor = 0.16;

  /// Obstacle size range, also relative to the shorter viewport edge.
  static const double obstacleMinWidthFactor = 0.055;
  static const double obstacleWidthJitter = 0.035;
  static const double obstacleMinHeightFactor = 0.10;
  static const double obstacleHeightJitter = 0.05;

  /// Spawn cadence. The base delay shrinks as the world speeds up, and the
  /// jitter keeps the rhythm from becoming memorisable.
  static const double baseSpawnDelay = 1.25;
  static const double spawnDelaySpeedBonus = 0.26;
  static const double spawnDelayJitter = 0.65;

  /// Particles emitted on collision.
  static const int impactParticleCount = 22;
  static const double impactParticleLifespan = 0.45;
}
