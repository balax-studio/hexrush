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
