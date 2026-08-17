import 'package:animate_do/animate_do.dart';
import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/widgets/glass_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

/// End-of-run card: final score, best score, and a restart button.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    required this.game,
    required this.isDarkMode,
    super.key,
  });

  static const String id = 'game_over';

  final DeepPurpleRunnerGame game;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.fromMode(isDarkMode: isDarkMode);

    return Positioned.fill(
      child: ColoredBox(
        color: CupertinoColors.black.withValues(alpha: 0.35),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 260),
            child: GlassCard(
              palette: palette,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlowText(
                    'GAME OVER',
                    blurRadius: 7,
                    glowColor: palette.neon,
                    style: GoogleFonts.pressStart2p(
                      color: palette.text,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<int>(
                    valueListenable: game.scoreNotifier,
                    builder: (context, score, child) {
                      return Text(
                        'Final score: $score',
                        style: GoogleFonts.orbitron(
                          color: palette.text.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.highScoreNotifier,
                    builder: (context, best, child) {
                      if (best <= 0) {
                        return const SizedBox.shrink();
                      }
                      final isNewRecord = game.scoreNotifier.value >= best;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          isNewRecord ? 'New best!' : 'Best: $best',
                          style: GoogleFonts.orbitron(
                            color: isNewRecord
                                ? palette.neon
                                : palette.text.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
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
                      onPressed: game.restart,
                      child: Text(
                        'Restart',
                        style: GoogleFonts.orbitron(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w700,
                        ),
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
