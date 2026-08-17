import 'package:animate_do/animate_do.dart';
import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/widgets/glass_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown while the run is frozen. Offers resume and restart.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({required this.game, required this.isDarkMode, super.key});

  static const String id = 'pause';

  final DeepPurpleRunnerGame game;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.fromMode(isDarkMode: isDarkMode);

    return Positioned.fill(
      child: ColoredBox(
        color: CupertinoColors.black.withValues(alpha: 0.3),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 200),
            child: GlassCard(
              palette: palette,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlowText(
                    'PAUSED',
                    blurRadius: 7,
                    glowColor: palette.neon,
                    style: GoogleFonts.pressStart2p(
                      color: palette.text,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlowContainer(
                    borderRadius: BorderRadius.circular(12),
                    color: palette.primary,
                    glowColor: palette.neon.withValues(alpha: 0.45),
                    blurRadius: 14,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      onPressed: game.resume,
                      child: Text(
                        'Resume',
                        style: GoogleFonts.orbitron(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    onPressed: game.restart,
                    child: Text(
                      'Restart',
                      style: GoogleFonts.orbitron(
                        color: palette.text.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
