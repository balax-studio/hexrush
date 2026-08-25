# HexRush ⚔️👑

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Flame Engine](https://img.shields.io/badge/Flame_Engine-FF6F00?style=for-the-badge&logo=flame&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-00E5FF?style=for-the-badge&logo=dart&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/Release-Store_Ready-success?style=for-the-badge)

**A tactile hexagonal idle conquest and tactical diorama builder in an isometric voxel world.**

[🎮 Play Live Web Demo](https://balax-studio.github.io/hexrush/) • [📦 Store Assets & ASO](store_assets/ASO_AND_STORE_READINESS.md) • [🔒 Privacy Policy](store_assets/PRIVACY_POLICY.md)

</div>

---

## 🌟 Overview

**HexRush** blends the instant dopamine gratification of tile-conquest mechanics with relaxing isometric voxel aesthetics and deep idle strategy. Start with a solitary Castle diorama, clear the fog of war, capture rich hexagonal resource nodes, establish automated production chains, and master the royal marketplace to build a thriving kingdom.

### 🎮 Core Gameplay Loops

- **Tactile Tile Conquest:** Clear the fog of war tile-by-tile with satisfying poof particle animations, floating resource yield popups, and smooth haptic feedback.
- **Isometric Voxel Diorama:** Real-time 2.5D voxel rendering with layered terrain heights, natural color palettes, and diorama lens camera controls (pan, zoom, frame).
- **Automated Production Guilds:** Construct and upgrade Timber Camps, Stone Quarries, Windmills, Bakeries, Foundries, and Watchtowers to boost your economy per second.
- **Dynamic Marketplace:** Exploit fluctuating market prices to trade surplus flour, wood, or stone for high-value strategic yields.
- **Royal Talents & Prestige Titles:** Earn Royal Crowns to ascend through the kingdom's talent tree and unlock sovereign titles with permanent production multipliers.
- **100% Offline-First:** Zero ads, zero tracking, and instant offline saving on your device.

---

## 🛠️ Architecture & Tech Stack

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

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.13.0` or higher
- Dart SDK `^3.1.0`

### Installation & Local Run
```bash
# Clone the repository
git clone https://github.com/balax-studio/hexrush.git
cd hexrush

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
flutter build web --release --base-href /hexrush/

# Android App Bundle (.aab for Google Play)
flutter build appbundle --release

# iOS (.ipa for App Store)
flutter build ipa --release
```

---

## 📱 Store Compliance & Readiness

HexRush is pre-configured and audited for zero-friction store submission:
- **Apple App Store:** `PrivacyInfo.xcprivacy` manifest included, `ITSAppUsesNonExemptEncryption = false` configured, and passes **Greenlight Preflight** with 0 issues.
- **Google Play Store:** Automated release keystore loading (`key.properties`), optimized ProGuard/R8 rules (`proguard-rules.pro`), and minimal permissions.
- **ASO Package:** Complete multi-language titles, keywords, screenshot storyboards, and nutrition label questionnaires located in [`store_assets/ASO_AND_STORE_READINESS.md`](store_assets/ASO_AND_STORE_READINESS.md).

---

## 📄 License & Credits

Developed with ❤️ by **Balax Games / Studio**.  
Licensed under the [MIT License](LICENSE).
