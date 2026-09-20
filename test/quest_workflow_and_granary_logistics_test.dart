import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/localization/game_localization.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/quest_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HexRush Görev Zinciri & 10x Gıda Lojistiği Testleri', () {
    test('Tahıl Deposu (granaryVault) işçinin 10 katı taşıma kapasitesine (33.6) sahiptir', () {
      const granary = BuildingModel(type: BuildingType.granaryVault, level: 1);
      const worker = BuildingModel(type: BuildingType.worker, level: 1);

      expect(granary.baseCarryingCapacity, closeTo(33.6, 0.01));
      expect(worker.baseCarryingCapacity, closeTo(3.36, 0.01));
      expect(granary.baseCarryingCapacity / worker.baseCarryingCapacity, closeTo(10.0, 0.01));
    });

    test('Terminoloji: Oduncu Kampı, Hızar Otağı ve Tahıl Deposu & Ambarı net ve çakışmasızdır', () {
      expect(GameLocalization.get('lumberjack_name', lang: 'tr'), 'Oduncu Kampı');
      expect(GameLocalization.get('sawmill_name', lang: 'tr'), 'Hızar Otağı');
      expect(GameLocalization.get('granary_vault_name', lang: 'tr'), 'Tahıl Deposu & Ambarı');
      expect(GameLocalization.get('lumberjack_name', lang: 'en'), 'Lumberjack Camp');
      expect(GameLocalization.get('sawmill_name', lang: 'en'), 'Sawmill Works');
      expect(GameLocalization.get('granary_vault_name', lang: 'en'), 'Granary Vault & Storehouse');
    });

    test('Görev Sıralaması: Fırın inşası Kervan kurma görevinden önce gelir (Ekmek blocker fix)', () {
      final notifier = GameStateNotifier();
      final quests = notifier.debugState.quests;

      final bakeryIndex = quests.indexWhere((q) => q.id == 'q_bakery_1');
      final caravanIndex = quests.indexWhere((q) => q.id == 'q_caravan_1');

      expect(bakeryIndex, isNot(-1));
      expect(caravanIndex, isNot(-1));
      expect(bakeryIndex, lessThan(caravanIndex),
          reason: 'Kervan bağlama görevi ekmek gerektirdiği için Fırın inşasından sonra gelmelidir.');
    });

    test('Seviye 10 Bina Görevleri: upgradeBuilding görevleri mevcuttur ve binaların en yüksek seviyesini takip eder', () {
      final notifier = GameStateNotifier();
      final quests = notifier.debugState.quests;

      final windmillUpgradeQuest = quests.firstWhere((q) => q.id == 'q_upgrade_windmill_10');
      expect(windmillUpgradeQuest.type, QuestType.upgradeBuilding);
      expect(windmillUpgradeQuest.targetBuilding, BuildingType.windmill);
      expect(windmillUpgradeQuest.targetAmount, 10);

      // Haritaya 10. seviye bir değirmen ekleyelim ve sync'i kontrol edelim
      const testCoord = HexAxial(1, 0);
      notifier.debugModifyState((s) {
        final updatedTiles = Map<HexAxial, HexTileModel>.from(s.tiles);
        updatedTiles[testCoord] = const HexTileModel(
          coord: testCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.windmill, level: 10),
        );
        return s.copyWith(tiles: updatedTiles);
      });

      // Seviye 10 değirmen sonrası görevin tamamlandığını kontrol edelim
      final updatedQuest = notifier.debugState.quests.firstWhere((q) => q.id == 'q_upgrade_windmill_10');
      expect(updatedQuest.currentAmount, 10);
      expect(updatedQuest.isCompleted, isTrue);
    });

    test('Kutlu Tapınak Fethi: Komşu karolara +%50 taşıma ve bereket sinerjisi kazandırır', () {
      const shrineCoord = HexAxial(0, 3);
      const neighborCoord = HexAxial(0, 2);

      const shrineTile = HexTileModel(
        coord: shrineCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        shrine: ShrineType.foodBoost,
      );

      const neighborTile = HexTileModel(
        coord: neighborCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );

      final synergyWithShrine = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: neighborTile,
        neighborTiles: [shrineTile],
        season: 'SPRING',
        isZud: false,
      );

      final synergyLabels = EconomyCalculator.getActiveSynergyLabels(
        targetTile: neighborTile,
        neighborTiles: [shrineTile],
        season: 'SPRING',
        isZud: false,
      );

      expect(synergyWithShrine, greaterThanOrEqualTo(1.50));
      expect(synergyLabels.any((l) => l.contains('Kutlu Tapınak')), isTrue);
    });

    test('Görev Ödül Ölçekleme: calculateQuestScaledReward ilerleyen görevlerde ödülleri artırır', () {
      const baseCrownReward = 10;
      final rewardEarly = EconomyCalculator.calculateQuestScaledReward(
        baseReward: baseCrownReward,
        questIndex: 1,
        castleLevel: 1,
      );
      final rewardLate = EconomyCalculator.calculateQuestScaledReward(
        baseReward: baseCrownReward,
        questIndex: 15,
        castleLevel: 10,
      );

      expect(rewardLate, greaterThan(rewardEarly));
      expect(rewardLate, greaterThanOrEqualTo(30));
    });
  });
}
