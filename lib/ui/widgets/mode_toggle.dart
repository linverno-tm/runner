import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/widgets/glass_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Segmented switch between the neon and pastel palettes.
///
/// Built by hand rather than with [CupertinoSlidingSegmentedControl] so the
/// selected pill can pick up the palette's glow.
class ModeToggle extends StatelessWidget {
  const ModeToggle({
    required this.isDarkMode,
    required this.palette,
    required this.onChanged,
    super.key,
  });

  static const Duration _animationDuration = Duration(milliseconds: 240);

  final bool isDarkMode;
  final AppPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isDarkMode
          ? 'Switch to pastel mode'
          : 'Switch to neon glow mode',
      child: GestureDetector(
        onTap: () => onChanged(!isDarkMode),
        child: GlassCard(
          palette: palette,
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: _animationDuration,
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
                      .withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: _animationDuration,
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
                          ? palette.neon.withValues(alpha: 0.24)
                          : palette.primary.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: _Label('Neon Glow', palette: palette)),
                    Expanded(child: _Label('Pastel', palette: palette)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.palette});

  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          color: palette.text,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
