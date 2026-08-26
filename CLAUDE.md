# Hex Idle - Kingdom & Economy Game (Flutter / Dart 3.x)

A high-performance, standalone isometric hexagonal idle kingdom and economy game built with **pure Flutter & Dart 3.x**.

## Technology Stack

- **Framework**: Flutter 3.x / Dart 3.x (Clean Architecture: Core, Domain, Data, Presentation)
- **Rendering**: Hardware-accelerated Flutter `CustomPainter` + `Canvas` (Pointy-top isometric hex grid)
- **State Management**: `flutter_riverpod` (StateNotifier & AsyncNotifier)
- **Local Persistence**: `shared_preferences` (JSON Save State with offline earnings simulation)
- **Localization**: TR, EN, ES, DE multi-language engine
- **Audio**: `audioplayers` sound effects and ambient BGM

## Project Structure

```
lib/
├── core/
│   ├── hex/             # HexAxial coordinates & HexMath calculations
│   ├── localization/    # Multi-language string tables
│   └── theme/           # Dark fantasy palette & typography
├── domain/
│   ├── economy/         # EconomyCalculator, multi-tier multipliers, seasons
│   └── models/          # HexTileModel, BuildingModel, GameStateModel
├── data/
│   └── save_repository.dart # Local storage & JSON serialization
└── presentation/
    ├── canvas/          # HexGridPainter & HexInteractiveMap (pan/zoom/hit-test)
    ├── providers/       # GameStateNotifier & game loop ticker
    ├── screens/         # GameScreen scaffold
    └── widgets/         # TopBarHUD, TileActionSheet, ToastOverlay, SettingsDialog
test/
├── hex_math_test.dart
├── economy_calculator_test.dart
├── game_state_test.dart
└── widget_test.dart
```

## Running & Testing

```bash
# Run Unit & Widget Tests
flutter test

# Run Locally on Web
flutter run -d chrome

# Run on Desktop (Windows)
flutter run -d windows

# Build Production Web Release
flutter build web --release
```

## Karpathy Behavioral Guidelines

Behavioral guidelines to reduce common LLM coding mistakes:

### 1. Think Before Coding
- **Don't assume. Don't hide confusion. Surface tradeoffs.**
- State your assumptions explicitly. If uncertain, ask rather than guess.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.

### 2. Simplicity First
- **Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.

### 3. Surgical Changes
- **Touch only what you must. Clean up only your own mess.**
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style. Every changed line should trace directly to the request.

### 4. Goal-Driven Execution
- **Define success criteria. Loop until verified.**
- Verify changes with tests (`flutter test`) before declaring complete.

