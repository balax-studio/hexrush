# Specification: HexRush Visual Elevation & Tactile Polish

## 1. Objective
Elevate the existing visual, tactile, and spatial aesthetic of HexRush to an Awwwards-tier / Apple Design Award level ($150k+ agency standard) without introducing any new gameplay rules or mechanics.

## 2. Tech Stack & Environment
- **Framework:** Flutter + Flame + Riverpod
- **Architecture:** Isometric Hex Grid with 2.5D Voxel Renderers
- **Design Language:** Archaeological Neo-Brutalism & Voxel Miniature Diorama
- **Rules Compliance:** Zero-GC inside render loops (static final Paint/Path pools), Zero-Emoji, Zero-Dark-Patterns, RepaintBoundary isolation.

## 3. Capability Map & Module Breakdown

| Module ID | Scope & Responsibility | Target Files |
| :--- | :--- | :--- |
| `harvest_juice` | Direct Tap Squash-Stretch, Parabolik Text / Particle Flight, HUD Punch Feedback | `harvest_sparkle_emitter.dart`, `harvest_floating_text_emitter.dart`, `top_bar_hud.dart`, `hex_tile_component.dart` |
| `voxel_depth_shadows` | 3-Tier Monolithic Terraced Mountains, 3px Submerged Riverbeds, 45° Directional Isometric Cast Shadows | `voxel_isometric_renderer.dart`, `hex_tile_component.dart` |
| `kinetic_buildings` | Windmill Wheat Dust, Mine Smoke Rings, Lumberjack Sawdust, Castle Banner Sway, Forge Embers | `voxel_isometric_renderer.dart`, `harvest_sparkle_emitter.dart` |
| `diorama_lens_clouds` | Drifting Cloud Caustics/Shadows, Tilt-Shift Diorama Focus Overlay, Seasonal Aura Grading | `diorama_lens_overlay.dart`, `hex_map_game.dart` |
| `tactile_ui_polish` | Double-Bezel Neo-Brutalist Frame Depth, Micro-Spring Button Physics, Smooth Numeric Rolling | `tactile_neo_button.dart`, `top_bar_hud.dart`, `tile_action_sheet.dart` |

## 4. Commands & Verification Gates
- **Test:** `flutter test`
- **Lint / Analyze:** `flutter analyze`
- **Zero-GC Invariant:** All `Paint()` and `Path()` allocations in Flame `render()` must be `static final` or component-pooled.

## 5. Success Criteria
1. When a tile is tapped for harvest, the voxel model performs a squash-stretch bounce and floating resource text curves dynamically toward the TopBarHUD.
2. Mountain tiles render as 3-tiered volumetric geological monoliths, and buildings cast subtle 45° ambient voxel shadows.
3. Production buildings emit ambient kinetic particles (smoke rings from iron mines, golden flour dust from windmills, swaying tuğ banners from Kağan Otağı).
4. Subtle atmospheric cloud shadows drift across the map in the game loop.
5. All 153+ Flutter tests pass without regressions, and 60 FPS zero-GC performance is maintained.
