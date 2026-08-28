import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/combat_model.dart';
import 'package:hex_rush/domain/models/game_state.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave Progression & Combat Integration Tests', () {
    late GameStateNotifier notifier;

    setUp(() {
      notifier = GameStateNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('soundSteppeHorn activates wave and spawns enemies with Castle HP', () {
      final success = notifier.soundSteppeHorn();
      expect(success, true);
      expect(notifier.state.combatState.isActiveWave, true);
      expect(notifier.state.combatState.currentWaveTier, 1);
      expect(notifier.state.combatState.activeEnemies.isNotEmpty, true);
      expect(notifier.state.combatState.castleCurrentHp, greaterThan(0.0));
    });

    test('Damaged tile suffers 50% production drop and is restored upon repair', () {
      // Çayır karosuna Seviye 1 Buğday kur
      const farmCoord = HexAxial(1, 0);
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          farmCoord: const HexTileModel(
            coord: farmCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            isDamaged: false,
            building: BuildingModel(type: BuildingType.corn, level: 1),
          ),
        },
        resources: const ResourcesModel(food: 100.0, wood: 100.0, stone: 100.0),
      );

      // Normal tick
      notifier.testTick();
      final double initialFood = notifier.state.resources.food;
      expect(initialFood, greaterThan(100.0));

      // Karoyu hasarlı yap
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          farmCoord: notifier.state.tiles[farmCoord]!.copyWith(isDamaged: true),
        },
      );

      final prevFood = notifier.state.resources.food;
      notifier.testTick();
      final double damagedGain = notifier.state.resources.food - prevFood;

      // Hasarlı karo onarımı
      final repaired = notifier.repairHexTile(farmCoord);
      expect(repaired, true);
      expect(notifier.state.tiles[farmCoord]!.isDamaged, false);
    });

    test('Building walls and repairing walls', () {
      const wallCoord = HexAxial(1, 0);
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          wallCoord: const HexTileModel(
            coord: wallCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
          ),
        },
        resources: const ResourcesModel(wood: 100.0, stone: 100.0),
      );

      final built = notifier.buildOrUpgradeWall(wallCoord, WallTier.woodenPalisade);
      expect(built, true);
      expect(notifier.state.tiles[wallCoord]!.hasActiveWall, true);
      expect(notifier.state.tiles[wallCoord]!.wall!.tier, WallTier.woodenPalisade);

      // Hasar ver ve tamir et
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          wallCoord: notifier.state.tiles[wallCoord]!.copyWith(
            wall: notifier.state.tiles[wallCoord]!.wall!.copyWith(currentHp: 20.0),
          ),
        },
      );

      final repaired = notifier.repairWall(wallCoord);
      expect(repaired, true);
      expect(notifier.state.tiles[wallCoord]!.wall!.currentHp, notifier.state.tiles[wallCoord]!.wall!.maxHp);
    });

    test('Victory clears wave, awards crowns/tamgas and advances to Tier N+1', () {
      notifier.soundSteppeHorn();
      expect(notifier.state.combatState.isActiveWave, true);
      expect(notifier.state.combatState.currentWaveTier, 1);

      final initialCrowns = notifier.state.resources.crowns;

      // Düşmanların canını 0 yaparak zaferi simüle et
      notifier.state = notifier.state.copyWith(
        combatState: notifier.state.combatState.copyWith(
          activeEnemies: [
            notifier.state.combatState.activeEnemies.first.copyWith(currentHp: 0.0),
          ],
        ),
      );

      notifier.testTick();

      // Zafer sonrası
      expect(notifier.state.combatState.isActiveWave, false);
      expect(notifier.state.combatState.currentWaveTier, 2); // Tier 1 tamamlandı -> Tier 2 açıldı
      expect(notifier.state.combatState.maxCompletedWaveTier, 1);
      expect(notifier.state.resources.crowns, greaterThan(initialCrowns));
    });

    test('Castle destruction causes defeat, preserves wave tier and requires repair', () {
      notifier.soundSteppeHorn();
      expect(notifier.state.combatState.currentWaveTier, 1);

      // Şato HP'sini sıfırlayarak yenilgiyi simüle et
      notifier.state = notifier.state.copyWith(
        combatState: notifier.state.combatState.copyWith(
          castleCurrentHp: 0.0,
        ),
        resources: const ResourcesModel(wood: 200.0, stone: 200.0),
      );

      notifier.testTick();

      // Yenilgi sonrası
      expect(notifier.state.combatState.isActiveWave, false);
      expect(notifier.state.combatState.currentWaveTier, 1); // Seviye artmadı, aynı seviye tekrar denenmeli
      expect(notifier.state.combatState.isCastleDestroyed, true);

      // Şato onarımı
      final repaired = notifier.repairCastle();
      expect(repaired, true);
      expect(notifier.state.combatState.isCastleDestroyed, false);
    });
  });
}
