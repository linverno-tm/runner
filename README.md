<div align="center">

# Deep Purple Runner
### Neon Glassmorphism Endless Runner built with Flutter + Flame

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flame](https://img.shields.io/badge/Flame-1.35.1-6A1B9A?style=for-the-badge)](https://pub.dev/packages/flame)
[![License](https://img.shields.io/badge/License-MIT-111111?style=for-the-badge)](LICENSE)

</div>

---

## Overview
**Deep Purple Runner** is a stylish endless runner prototype focused on:
- smooth gameplay loop,
- modern neon + glassmorphism visuals,
- responsive behavior for mobile and web,
- clean modular architecture inside Flame components.

The player jumps over incoming obstacles. Speed and challenge scale over time. One collision ends the run.

---

## Visual Direction
- **Style:** Glow + Glassmorphism
- **Mood:** Sci-fi night / cosmic depth
- **Primary Palette:**
  - `#0F0C29` -> `#302B63` (background gradient)
  - `#673AB7` / `#7E57C2` (primary)
  - `#BD00FF` (neon glow)
- **UI Language:** Cupertino-inspired minimal surfaces with blur and rounded corners

---

## Core Features
- Modular Flame game structure:
  - `DeepPurpleRunnerGame` (GameClass)
  - `PlayerComponent`
  - `ObstacleComponent`
  - `GradientBackgroundComponent`
- Physics-driven jump system:
  - gravity
  - tap-to-jump
  - grounded-state logic
- Collision detection with `RectangleHitbox`
- Collision particle burst effect
- Dynamic score system with pulse animation
- Custom Neon/Pastel mode toggle
- iOS-style glass HUD and Game Over modal
- Fully responsive scaling for web + mobile

---

## Project Structure
```text
lib/
  main.dart
```

> Note: This prototype is intentionally delivered in a single `main.dart` file while still keeping component-level separation in code.

---

## Tech Stack
- **Flutter** (UI shell, overlays, responsive layout)
- **Flame Engine** (game loop, components, collision)
- **flutter_glow** (neon glow UI widgets)
- **animate_do** (UI entrance micro-animations)
- **google_fonts** (Orbitron / Press Start 2P)

---

## Getting Started
### 1) Clone
```bash
git clone https://github.com/<your-username>/deep-purple-runner.git
cd deep-purple-runner
```

### 2) Install dependencies
```bash
flutter pub get
```

### 3) Run
```bash
flutter run
```

### Web run
```bash
flutter run -d chrome
```

---

## Controls
- **Tap / Click**: Jump
- **Avoid obstacles**: Survive as long as possible
- **Game Over modal**: Press `Restart` to play again

---

## Gameplay Notes
- Difficulty scales with speed increase.
- Obstacle timing is randomized within tuned boundaries.
- Score increases over survival time.

---

## Screenshots / Preview
Add your visuals for stronger GitHub presentation:

```text
assets/readme/cover.png
assets/readme/gameplay.gif
```

Then embed:

```md
<p align="center">
  <img src="assets/readme/cover.png" width="900" alt="Deep Purple Runner cover" />
</p>

<p align="center">
  <img src="assets/readme/gameplay.gif" width="900" alt="Deep Purple Runner gameplay" />
</p>
```

---

## Roadmap
- sound effects + background music
- collectible boosts
- pause/resume system
- leaderboard integration
- persistent high score storage

---

## Contribution
PRs and issue reports are welcome.

If you want to contribute:
1. Fork repository
2. Create branch: `feature/your-feature-name`
3. Commit and push
4. Open Pull Request

---

## License
MIT License. You can use, modify, and distribute this project freely.
