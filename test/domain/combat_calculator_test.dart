import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/combat_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/combat_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('CombatCalculator Tests', () {
    test('BuildingType.watchtower unlocks at Castle Level 5', () {
      expect(BuildingType.watchtower.requiredCastleLevel, 5);
    });

    test('calculateCastleMaxHp scales with castle level', () {
      expect(CombatCalculator.calculateCastleMaxHp(1), 150.0);
      expect(CombatCalculator.calculateCastleMaxHp(2), 270.0);
      expect(CombatCalculator.calculateCastleMaxHp(5), 630.0);
      expect(CombatCalculator.calculateCastleMaxHp(10), 1230.0);
    });

    test('calculateTowerStats enforces R=3 and scales stats with level', () {
      final statsLvl1 = CombatCalculator.calculateTowerStats(1);
      expect(statsLvl1.range, 3);
      expect(statsLvl1.damage, 18.0);
      expect(statsLvl1.cooldownSeconds, 1.25);
      expect(statsLvl1.isAoE, false);

      final statsLvl5 = CombatCalculator.calculateTowerStats(5);
      expect(statsLvl5.range, 3);
      expect(statsLvl5.damage, greaterThan(statsLvl1.damage));
      expect(statsLvl5.cooldownSeconds, lessThan(statsLvl1.cooldownSeconds));
      expect(statsLvl5.isAoE, true);
    });

    test('calculateTowerUpgradeCost dynamically adapts to Tier 1-4 resources', () {
      // Tier 1: Odun & Taş
      final costTier1 = CombatCalculator.calculateTowerUpgradeCost(1);
      expect(costTier1.containsKey('wood'), true);
      expect(costTier1.containsKey('stone'), true);
      expect(costTier1.containsKey('plank'), false);

      // Tier 2: Kereste & Ekmek
      final costTier2 = CombatCalculator.calculateTowerUpgradeCost(3);
      expect(costTier2.containsKey('plank'), true);
      expect(costTier2.containsKey('bread'), true);

      // Tier 3: Demir & Keçe & Kımız
      final costTier3 = CombatCalculator.calculateTowerUpgradeCost(6);
      expect(costTier3.containsKey('iron'), true);
      expect(costTier3.containsKey('felt'), true);
      expect(costTier3.containsKey('kumis'), true);

      // Tier 4: Şam Çeliği & Obsidyen & Bilgelik
      final costTier4 = CombatCalculator.calculateTowerUpgradeCost(8);
      expect(costTier4.containsKey('damascusSteel'), true);
      expect(costTier4.containsKey('obsidian'), true);
      expect(costTier4.containsKey('wisdom'), true);
    });

    test('calculateWallCost and repair cost', () {
      final woodWallCost = CombatCalculator.calculateWallCost(WallTier.woodenPalisade);
      expect(woodWallCost['wood'], 25.0);

      final stoneWallCost = CombatCalculator.calculateWallCost(WallTier.stoneRampart);
      expect(stoneWallCost['stone'], 45.0);

      final ironWallCost = CombatCalculator.calculateWallCost(WallTier.ironFortification);
      expect(ironWallCost['iron'], 35.0);

      const wall = CombatWallModel(tier: WallTier.woodenPalisade, currentHp: 75.0);
      final repairCost = CombatCalculator.calculateWallRepairCost(wall);
      expect(repairCost.containsKey('wood'), true);
      expect(repairCost['wood'], greaterThan(0.0));
    });

    test('calculateTileRepairCost gives 50% building upgrade cost', () {
      const tile = HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        isDamaged: true,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );

      final repairCost = CombatCalculator.calculateTileRepairCost(tile);
      expect(repairCost.isNotEmpty, true);
      expect(repairCost['food'], greaterThan(0.0));
    });

    test('selectFarthestSpawnPoints picks outermost boundary tiles', () {
      final tiles = {
        const HexAxial(0, 0): const HexTileModel(coord: HexAxial(0, 0), biome: TileBiome.meadow, state: TileState.owned),
        const HexAxial(1, 0): const HexTileModel(coord: HexAxial(1, 0), biome: TileBiome.meadow, state: TileState.owned),
        const HexAxial(3, 0): const HexTileModel(coord: HexAxial(3, 0), biome: TileBiome.meadow, state: TileState.discovered),
        const HexAxial(0, 4): const HexTileModel(coord: HexAxial(0, 4), biome: TileBiome.forest, state: TileState.discovered),
        const HexAxial(0, 5): const HexTileModel(coord: HexAxial(0, 5), biome: TileBiome.mountain, state: TileState.discovered),
      };

      final spawns = CombatCalculator.selectFarthestSpawnPoints(
        tiles: tiles,
        castleCoord: const HexAxial(0, 0),
        maxSpawns: 2,
      );

      expect(spawns.isNotEmpty, true);
      expect(spawns.every((s) => s != const HexAxial(0, 0)), true);
    });

    test('generateWave scales enemy count with waveTier and targets castle', () {
      final tiles = {
        const HexAxial(0, 0): const HexTileModel(coord: HexAxial(0, 0), biome: TileBiome.meadow, state: TileState.owned),
        const HexAxial(1, 0): const HexTileModel(coord: HexAxial(1, 0), biome: TileBiome.meadow, state: TileState.owned),
        const HexAxial(2, 0): const HexTileModel(coord: HexAxial(2, 0), biome: TileBiome.meadow, state: TileState.owned),
      };

      final enemiesTier1 = CombatCalculator.generateWave(
        waveTier: 1,
        boundaryCoords: [const HexAxial(2, 0)],
        castleCoord: const HexAxial(0, 0),
        tiles: tiles,
      );

      final enemiesTier5 = CombatCalculator.generateWave(
        waveTier: 5,
        boundaryCoords: [const HexAxial(2, 0)],
        castleCoord: const HexAxial(0, 0),
        tiles: tiles,
      );

      expect(enemiesTier1.length, 7); // 4 + 1*3
      expect(enemiesTier5.length, 19); // 4 + 5*3
      expect(enemiesTier5.length, greaterThan(enemiesTier1.length));
      expect(enemiesTier1.first.path.last, const HexAxial(0, 0));
    });

    test('calculateWaveVictoryReward scales with waveTier', () {
      final rTier1 = CombatCalculator.calculateWaveVictoryReward(1);
      expect(rTier1.crowns, 5);
      expect(rTier1.resources['wood'], 25.0);

      final rTier5 = CombatCalculator.calculateWaveVictoryReward(5);
      expect(rTier5.crowns, 13);
      expect(rTier5.tamgas, 1);
      expect(rTier5.resources['iron'], greaterThan(0.0));
    });

    test('Wall obstacle stops enemy, takes damage, and opens path upon breach', () {
      var wall = const CombatWallModel(tier: WallTier.woodenPalisade, currentHp: 50.0);
      expect(wall.isBreached, false);

      const double enemyDps = 25.0;
      const double dt = 1.0;

      // Saniyede 25 hasar: 1. saniye sonrası (50 - 25 = 25 HP, henüz yıkılmadı)
      wall = wall.copyWith(currentHp: wall.currentHp - enemyDps * dt);
      expect(wall.currentHp, 25.0);
      expect(wall.currentHp <= 0, false);

      // 2. saniye sonrası (25 - 25 = 0 HP, sur yıkıldı!)
      final double newHp = wall.currentHp - enemyDps * dt;
      wall = wall.copyWith(currentHp: newHp, isBreached: newHp <= 0.0);
      expect(wall.currentHp, 0.0);
      expect(wall.isBreached, true);
    });
  });
}
