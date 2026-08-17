import 'package:animate_do/animate_do.dart';
import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/ui/widgets/glass_card.dart';
import 'package:endless_runner/ui/widgets/mode_toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top bar shown during a run: palette toggle, pause, score and best score.
class HudOverlay extends StatelessWidget {
  const HudOverlay({
    required this.game,
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  static const String id = 'hud';

  final DeepPurpleRunnerGame game;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = game.palette;

    return FadeInDown(
      duration: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModeToggle(
              isDarkMode: isDarkMode,
              palette: palette,
              onChanged: onThemeChanged,
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Pause',
              child: GestureDetector(
                onTap: game.pause,
                child: GlassCard(
                  palette: palette,
                  padding: const EdgeInsets.all(11),
                  child: Icon(
                    CupertinoIcons.pause_fill,
                    size: 20,
                    color: palette.text,
                  ),
                ),
              ),
            ),
            const Spacer(),
            _ScorePanel(game: game),
          ],
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.game});

  final DeepPurpleRunnerGame game;

  @override
  Widget build(BuildContext context) {
    final palette = game.palette;

    return GlassCard(
      palette: palette,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (context, score, child) {
              // Keyed so a new tween runs on every point, producing the pulse.
              return TweenAnimationBuilder<double>(
                key: ValueKey<int>(score),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: 1.2, end: 1),
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: GlowText(
                  'SCORE $score',
                  blurRadius: 6,
                  glowColor: palette.neon,
                  style: GoogleFonts.orbitron(
                    color: palette.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 1.1,
                  ),
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
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'BEST $best',
                  style: GoogleFonts.orbitron(
                    color: palette.text.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
