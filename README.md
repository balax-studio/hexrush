# HexRush

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Flame Engine](https://img.shields.io/badge/Flame_Engine-FF6F00?style=for-the-badge&logo=flame&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-00E5FF?style=for-the-badge&logo=dart&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/Release-Store_Ready-success?style=for-the-badge)

**A tactile hexagonal idle conquest and tactical diorama builder in an isometric voxel world.**

[Play Live Web Demo](https://ismailgulbag95.github.io/altigen.vs1/) • [Store Assets & ASO](store_assets/ASO_AND_STORE_READINESS.md) • [Privacy Policy](store_assets/PRIVACY_POLICY.md)

</div>

---

## Overview

HexRush combines tactical tile-conquest mechanics with relaxing isometric voxel aesthetics and idle economy management. Players expand outwards from a central Castle diorama, clear the fog of war across hex tiles, construct production chains, trade in the royal marketplace, and unlock persistent talents.

### Core Gameplay Loops

- **Tile Conquest:** Expand territory tile-by-tile across distinct biomes (meadow, forest, mountain, sea) with tactile feedback.
- **Isometric Voxel Diorama:** Real-time 2.5D voxel rendering with layered terrain heights, natural color palettes, and camera pan/zoom controls.
- **Automated Production Guilds:** Build and upgrade Timber Camps, Stone Quarries, Windmills, Bakeries, Foundries, and Watchtowers.
- **Dynamic Marketplace:** Trade excess goods for high-tier construction materials and Royal Crowns.
- **Talents & Titles:** Ascend through the kingdom's talent tree and claim sovereign titles for global production bonuses.
- **Offline Progression:** Offline calculation and local device persistence without external tracking.

---

## Architecture & Tech Stack

```
lib/
├── core/
│   └── hex/                   # Hexagonal axial math, conversions & pathfinding
├── domain/
│   ├── economy/               # Production formulas, multipliers & offline calc
│   └── models/                # Immutable GameState, HexTile, Building models
├── data/                      # SharedPreferences local save repository
└── presentation/
    ├── flame/                 # Flame game, voxel isometric renderer & particle emitters
    ├── providers/             # Riverpod StateNotifier state management
    ├── screens/               # Flutter game screen & HUD overlays
    └── widgets/               # Bottom drawer, talent tree, market & diorama UI
```

- **Engine:** Flutter + Flame Engine (custom isometric voxel components & particle emitters)
- **State Management:** Flutter Riverpod 2.x (`GameStateNotifier`)
- **Package Identifier:** `com.balax.hexrush`
- **Platforms:** Android, iOS, Web, Windows, macOS, Linux

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.13.0` or higher
- Dart SDK `^3.1.0`

### Installation & Local Run
```bash
# Clone the repository
git clone https://github.com/ismailgulbag95/altigen.vs1.git
cd altigen.vs1

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run locally on your device or browser
flutter run
```

### Building for Release

```bash
# Web (GitHub Pages / Web Hosting)
flutter build web --release --base-href /altigen.vs1/ --no-web-resources-cdn

# Android App Bundle (.aab for Google Play)
flutter build appbundle --release

# iOS (.ipa for App Store)
flutter build ipa --release
```

---

## Store Compliance & Readiness

HexRush is configured and audited for store submission:
- **Apple App Store:** `PrivacyInfo.xcprivacy` manifest included, `ITSAppUsesNonExemptEncryption = false` configured, and passes Greenlight Preflight with 0 issues.
- **Google Play Store:** Automated release keystore loading (`key.properties`), optimized ProGuard rules (`proguard-rules.pro`), and minimal permission footprints.
- **ASO Package:** Multi-language titles, keywords, screenshot storyboards, and privacy documentation located in [`store_assets/ASO_AND_STORE_READINESS.md`](store_assets/ASO_AND_STORE_READINESS.md).

---

## License & Credits

Developed by **Balax Games / Studio**.  
Licensed under the [MIT License](LICENSE).� License & Credits

Developed with ❤️ by **Balax Games / Studio**.  
Licensed under the [MIT License](LICENSE).
