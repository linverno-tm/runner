import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Fills the viewport with the palette's background ramp.
///
/// Rendered as a component rather than a Flutter widget so it sits underneath
/// the player and obstacles in the same canvas and repaints with them.
class GradientBackgroundComponent extends Component
    with HasGameReference<DeepPurpleRunnerGame> {
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [game.palette.backgroundStart, game.palette.backgroundEnd],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }
}
