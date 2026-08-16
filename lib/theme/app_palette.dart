import 'package:flutter/cupertino.dart';

/// Colour set for a single visual mode.
///
/// The game reads its palette through [DeepPurpleRunnerGame.palette] so the
/// Flame components and the Flutter overlays always draw from one source.
@immutable
class AppPalette {
  const AppPalette({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.primary,
    required this.neon,
    required this.surface,
    required this.text,
  });

  /// Neon glow mode - deep cosmic purple with a magenta accent.
  static const AppPalette neonGlow = AppPalette(
    backgroundStart: Color(0xFF0F0C29),
    backgroundEnd: Color(0xFF302B63),
    primary: Color(0xFF673AB7),
    neon: Color(0xFFBD00FF),
    surface: Color(0x8021242E),
    text: CupertinoColors.white,
  );

  /// Pastel mode - the same layout on a light, low-contrast ramp.
  static const AppPalette pastel = AppPalette(
    backgroundStart: Color(0xFFF5F1FF),
    backgroundEnd: Color(0xFFDDE2F7),
    primary: Color(0xFF7E57C2),
    neon: Color(0xFF9B6DFF),
    surface: Color(0x80FFFFFF),
    text: Color(0xFF1A1A1A),
  );

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color primary;
  final Color neon;
  final Color surface;
  final Color text;

  static AppPalette fromMode({required bool isDarkMode}) {
    return isDarkMode ? neonGlow : pastel;
  }
}
