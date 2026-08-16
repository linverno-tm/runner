import 'dart:ui';

import 'package:endless_runner/theme/app_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_glow/flutter_glow.dart';

/// Frosted, softly glowing surface used by every overlay.
///
/// Centralising the blur radius, border and glow here keeps the HUD, the pause
/// card and the game-over card visually identical.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    super.key,
  });

  static const double _radius = 12;
  static const double _blurSigma = 12;

  final AppPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: GlowContainer(
          borderRadius: BorderRadius.circular(_radius),
          color: palette.surface,
          glowColor: palette.neon.withValues(alpha: 0.25),
          blurRadius: 10,
          spreadRadius: 0.3,
          padding: padding,
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.18),
          ),
          child: child,
        ),
      ),
    );
  }
}
