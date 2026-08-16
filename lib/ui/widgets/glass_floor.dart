import 'dart:ui';

import 'package:endless_runner/game/game_config.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:flutter/cupertino.dart';

/// The blurred strip along the bottom of the screen that reads as ground.
///
/// Drawn as a Flutter overlay rather than a Flame component so it can use a
/// real backdrop blur over the game canvas. Its height matches
/// [GameConfig.groundHeightFactor], which is also what the game uses to place
/// the collision floor.
class GlassFloor extends StatelessWidget {
  const GlassFloor({required this.palette, super.key});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final floorHeight =
              constraints.maxHeight * GameConfig.groundHeightFactor;

          return Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: floorHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.2),
                    border: Border(
                      top: BorderSide(
                        color: palette.neon.withValues(alpha: 0.95),
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
