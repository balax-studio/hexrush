# Plan: World Visual Elevation & Architectural Dynamics

## Execution Sequence

### Phase 1: Module `building_tiers` (Bina Seviye Evrimi)
- [x] Task 1.1: Upgrade `drawVoxelWindmill` with Level 1-3 (Rustic Wood), Level 4-7 (Stone Masonry Base), Level 8-10+ (Imperial Gilded Spire & 4 Blades).
- [x] Task 1.2: Upgrade `drawVoxelMine` with Level 1-3 (Log Tunnel), Level 4-7 (Track & Stone Arch), Level 8-10+ (Twin Chimneys & Foundry Kiln).
- [x] Task 1.3: Upgrade `drawVoxelBakery`, `drawVoxelLumberjack`, `drawVoxelSawmill`, `drawVoxelQuarry` with tiered architectural variants.
- [x] Task 1.4: Update `HexTileComponent` building dispatch switch to pass `tile.building?.level ?? 1`.
- [x] Task 1.5: Verify with `flutter test`.

### Phase 2: Module `construction_drop_physics` (İnşaat Düşme & Oturma Fiziği)
- [x] Task 2.1: Enhance `HexTileComponent._buildBounceTimer` with vertical drop curve (`-18 * (1 - p/0.6)^2`) and landing squash-stretch settle curve.
- [x] Task 2.2: Verify with `flutter test`.

### Phase 3: Module `seasonal_winter_caps` (Mevsimsel Kar Örtüsü)
- [x] Task 3.1: Add `isWinter` support to building roof caps and pine boughs in `VoxelIsometricRenderer`.
- [x] Task 3.2: Verify with `flutter test`.

### Phase 4: Module `micro_fauna_flora` & `synergy_connections`
- [x] Task 4.1: Maintain idle grazing head-bob and tail-sway motions in `drawVoxelHorse` and `drawVoxelSheep`.
- [x] Task 4.2: Support winter and seasonal ground accents across biomes.
- [x] Task 4.3: Run full verification (`flutter test` 153/153 passed).
