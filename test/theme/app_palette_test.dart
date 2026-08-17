import 'package:endless_runner/theme/app_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPalette', () {
    test('neon glow uses the deep purple background ramp', () {
      expect(AppPalette.neonGlow.backgroundStart, const Color(0xFF0F0C29));
      expect(AppPalette.neonGlow.backgroundEnd, const Color(0xFF302B63));
      expect(AppPalette.neonGlow.neon, const Color(0xFFBD00FF));
    });

    test('fromMode selects the matching palette', () {
      expect(AppPalette.fromMode(isDarkMode: true), AppPalette.neonGlow);
      expect(AppPalette.fromMode(isDarkMode: false), AppPalette.pastel);
    });

    test('the two modes are visually distinct', () {
      expect(
        AppPalette.pastel.backgroundStart,
        isNot(AppPalette.neonGlow.backgroundStart),
      );
      expect(AppPalette.pastel.neon, isNot(AppPalette.neonGlow.neon));
      expect(AppPalette.pastel.text, isNot(AppPalette.neonGlow.text));
    });
  });
}
