<h1 align="center">Deep Purple Runner</h1>

<p align="center">
  Neon glassmorphism endless runner built with <b>Flutter</b> + <b>Flame</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Flame-FF6B35?style=flat-square&logo=flame&logoColor=white" />
  <img src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web-0468D7?style=flat-square" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" />
</p>

<p align="center">
  <a href="https://github.com/linverno-tm/runner/actions/workflows/flutter_ci.yml">
    <img src="https://github.com/linverno-tm/runner/actions/workflows/flutter_ci.yml/badge.svg" alt="CI" />
  </a>
</p>

---

## Overview

Tap to jump, survive as long as you can. Speed ramps up over time and one
collision ends the run. The whole thing is built around a small, testable core:
the game owns run state, components own their own physics and rendering, and
the Flutter overlays read from the same palette the canvas draws with.

**Highlights**

- Physics-driven jump with asymmetric gravity — falling is heavier than rising,
  so the arc feels responsive instead of floaty
- Difficulty curve that scales both world speed and spawn cadence, with jitter
  so the rhythm cannot be memorised
- Persistent high score, pause/resume, and two palettes (Neon Glow / Pastel)
- Frosted glass HUD and modals that scale from phone to desktop web
- 24 tests covering layout, jump physics, difficulty progression, pause,
  game-over/restart and high-score persistence

## Visual direction

| | |
|---|---|
| **Style** | Neon glow + glassmorphism |
| **Mood** | Sci-fi night, cosmic depth |
| **Background** | `#0F0C29` → `#302B63` |
| **Primary** | `#673AB7` / `#7E57C2` |
| **Neon accent** | `#BD00FF` |
| **Type** | Orbitron (HUD), Press Start 2P (titles) |

Pastel mode keeps the same layout on a light, low-contrast ramp.

## Architecture

```
lib/
├── main.dart                    # entry point
├── app.dart                     # CupertinoApp + GameWidget + overlay wiring
│
├── theme/
│   └── app_palette.dart         # the two palettes, shared by canvas and UI
│
├── game/
│   ├── deep_purple_runner_game.dart   # run state, spawning, scoring
│   ├── game_config.dart               # every tuning constant, in one place
│   └── components/
│       ├── player_component.dart          # gravity, jump, landing, collision
│       ├── obstacle_component.dart        # scroll, oscillate, self-cull
│       └── gradient_background_component.dart
│
├── services/
│   └── high_score_store.dart    # interface + SharedPreferences and fake impls
│
└── ui/
    ├── overlays/
    │   ├── hud_overlay.dart         # score, best, pause, palette toggle
    │   ├── pause_overlay.dart
    │   └── game_over_overlay.dart
    └── widgets/
        ├── glass_card.dart          # the frosted surface every overlay uses
        ├── glass_floor.dart
        └── mode_toggle.dart
```

Three ideas hold this together:

**Tuning is data, not code.** Every constant that shapes the feel of the game
lives in `GameConfig`. The difficulty curve is reviewable without reading the
game loop, and tests assert against named constants rather than magic numbers.

**One palette, two renderers.** Flame components and Flutter overlays both read
`DeepPurpleRunnerGame.palette`, so switching modes can never leave the canvas
and the chrome disagreeing.

**Storage behind an interface.** `HighScoreStore` has a `SharedPreferences`
implementation for the app and an in-memory one for tests, so the game is
testable without platform channels.

## Getting started

```bash
git clone https://github.com/linverno-tm/runner.git
cd runner
flutter pub get
```

Run it:

```bash
flutter run              # connected device or emulator
flutter run -d chrome    # web
```

## Controls

| Input | Action |
|---|---|
| Tap / click | Jump (ignored while airborne — no double jump) |
| Pause button | Freeze the run, then Resume or Restart |
| Neon / Pastel toggle | Switch palette live |

## Tests

```bash
flutter analyze
flutter test
```

The suite drives the real game loop rather than mocking it:

- **layout** — ground line derived from the viewport, player anchored to it
- **jumping** — impulse applied, double jump rejected, landing restores state
- **run progression** — score accrues, world speed clamps, obstacles spawn
- **pause** — score frozen while paused, resumes cleanly, no-op after game over
- **game over / restart** — overlay shown, world cleared, second hit ignored
- **high score** — restored on load, better runs persisted, worse runs ignored

CI runs analyze, the full suite, a release web build and a debug APK build on
every push.

## Roadmap

- [ ] Sound effects and background music
- [ ] Collectible boosts
- [ ] Online leaderboard
- [ ] Additional obstacle types

## License

MIT — see [LICENSE](LICENSE).
