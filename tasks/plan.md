# Implementation Plan: Visual Elevation & Tactile Polish

## Execution Sequence

### Phase 1: Module `harvest_juice` (Hasat Yaylanması, Parabolik Uçuş & HUD Punch)
- [x] Task 1.1: Enhance `HexTileComponent` with `harvestSquashTime` / squash-stretch vertical spring bounce on tap.
- [x] Task 1.2: Enhance `FloatingResourceNumberComponent` with curved/parabolic velocity and double-bezel alpha fading.
- [x] Task 1.3: Verify with unit tests (`flutter test test/direct_tap_harvest_test.dart`).

### Phase 2: Module `voxel_depth_shadows` (Yükseklik Teraslama & İzometrik Gölgeler)
- [x] Task 2.1: Enhance `VoxelIsometricRenderer.drawVoxelMountainVariant` with 3-tiered monolithic basalt terraces.
- [x] Task 2.2: Add directional cast voxel shadow projection behind tall buildings and mountains in `VoxelIsometricRenderer`.
- [x] Task 2.3: Enhance `drawVoxelWater` & `drawVoxelShorelineWaves` with submerged riverbed depth and edge shoreline borders.

### Phase 3: Module `kinetic_buildings` (Yaşayan Binalar & Hacimsel Parçacıklar)
- [x] Task 3.1: Add procedural chimney smoke rings and glowing furnace embers to Iron Mine (`drawVoxelMine`).
- [x] Task 3.2: Add ambient golden flour dust beneath rotating Windmill blades (`drawVoxelWindmill`).
- [x] Task 3.3: Add wind-swayed imperial tuğ banners & campfire torches to Kağan Otağı (`drawVoxelCastle`).

### Phase 4: Module `diorama_lens_clouds` (Atmosferik Bulut Gölgeleri & Tilt-Shift)
- [x] Task 4.1: Implement wide-roam drifting cloud shadows with dual-layer ground silhouettes in `FloatingVoxelCloudComponent`.
- [x] Task 4.2: Enhance `DioramaLensOverlay` with subtle tilt-shift diorama vignette and seasonal tone gradings.

### Phase 5: Module `tactile_ui_polish` (Neo-Brutalist Taktil Yay Fiziği & Double-Bezel)
- [x] Task 5.1: Enhance `TactileNeoButton` with 2px offset physical press travel, shadow collapse, and spring release.
- [x] Task 5.2: Enhance `TopBarHUD` and `TileActionSheet` with double-bezel layered borders and smooth numeric displays.

### Phase 6: Final Verification & Test Suite
- [x] Task 6.1: Run full test suite (`flutter test`) and verify 100% pass rate (153/153 passed).
- [x] Task 6.2: Ensure Zero-GC allocations and zero-emoji compliance.
