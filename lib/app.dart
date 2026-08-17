import 'package:endless_runner/game/deep_purple_runner_game.dart';
import 'package:endless_runner/theme/app_palette.dart';
import 'package:endless_runner/ui/overlays/game_over_overlay.dart';
import 'package:endless_runner/ui/overlays/hud_overlay.dart';
import 'package:endless_runner/ui/overlays/pause_overlay.dart';
import 'package:endless_runner/ui/widgets/glass_floor.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

/// Hosts the game canvas and its Flutter overlays.
///
/// The palette lives here rather than inside the game so both the Cupertino
/// chrome and the Flame components switch modes in the same frame.
class DeepPurpleRunnerApp extends StatefulWidget {
  const DeepPurpleRunnerApp({super.key});

  @override
  State<DeepPurpleRunnerApp> createState() => _DeepPurpleRunnerAppState();
}

class _DeepPurpleRunnerAppState extends State<DeepPurpleRunnerApp> {
  bool _isDarkMode = true;
  late final DeepPurpleRunnerGame _game;

  @override
  void initState() {
    super.initState();
    _game = DeepPurpleRunnerGame(isDarkMode: _isDarkMode);
  }

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
      _game.setThemeMode(isDarkMode: isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.fromMode(isDarkMode: _isDarkMode);

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Deep Purple Runner',
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: palette.primary,
        scaffoldBackgroundColor: palette.backgroundStart,
      ),
      home: CupertinoPageScaffold(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: GameWidget<DeepPurpleRunnerGame>(
                  game: _game,
                  overlayBuilderMap: {
                    HudOverlay.id: (context, game) => HudOverlay(
                      game: game,
                      isDarkMode: _isDarkMode,
                      onThemeChanged: _toggleTheme,
                    ),
                    PauseOverlay.id: (context, game) =>
                        PauseOverlay(game: game, isDarkMode: _isDarkMode),
                    GameOverOverlay.id: (context, game) =>
                        GameOverOverlay(game: game, isDarkMode: _isDarkMode),
                  },
                  initialActiveOverlays: const [HudOverlay.id],
                ),
              ),
              GlassFloor(palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}
