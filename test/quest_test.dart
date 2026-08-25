import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/quest_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QuestModel Tests', () {
    test('Quest progress and completion calculation', () {
      const quest = QuestModel(
        id: 'test_q',
        titleTr: 'Test Görevi',
        titleEn: 'Test Quest',
        descriptionTr: 'Test Açıklama',
        descriptionEn: 'Test Description',
        type: QuestType.conquerTiles,
        targetAmount: 5,
        currentAmount: 2,
        rewardType: QuestRewardType.food,
        rewardAmount: 50,
      );

      expect(quest.progress, 0.4);
      expect(quest.isCompleted, false);

      final updated = quest.copyWith(currentAmount: 5, isCompleted: true);
      expect(updated.progress, 1.0);
      expect(updated.isCompleted, true);
    });

    test('Quest JSON serialization round-trip', () {
      const quest = QuestModel(
        id: 'q_json',
        titleTr: 'Bozkır',
        titleEn: 'Steppe',
        descriptionTr: 'Açıklama',
        descriptionEn: 'Description',
        type: QuestType.buildStructure,
        targetBuilding: BuildingType.corn,
        targetAmount: 3,
        currentAmount: 1,
        rewardType: QuestRewardType.wood,
        rewardAmount: 100,
        isCompleted: false,
        isClaimed: false,
      );

      final json = quest.toJson();
      final fromJson = QuestModel.fromJson(json);

      expect(fromJson.id, quest.id);
      expect(fromJson.targetBuilding, BuildingType.corn);
      expect(fromJson.rewardType, QuestRewardType.wood);
      expect(fromJson.rewardAmount, 100);
    });
  });

  group('Net Resource Rates Tests', () {
    test('EconomyCalculator calculateNetRates computes correct food rate', () {
      final tiles = [
        const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
      ];

      final rates = EconomyCalculator.calculateNetRates(
        tiles: tiles,
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
      );

      expect(rates.food, greaterThan(0.0));
      expect(rates.wood, 0.0);
    });
  });

  group('GameStateNotifier Quest Integration Tests', () {
    test('Initial state contains quests and tracks progress', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;

      expect(state.quests.isNotEmpty, true);
      expect(state.quests.first.id, 'q_corn_1');

      notifier.dispose();
    });

    test('Claiming completed quest adds rewards', () {
      final notifier = GameStateNotifier();
      
      // Tamamlanmış bir test görevi ekle
      const completedQuest = QuestModel(
        id: 'q_instant',
        titleTr: 'Hızlı Görev',
        titleEn: 'Instant Quest',
        descriptionTr: 'Test',
        descriptionEn: 'Test',
        type: QuestType.conquerTiles,
        targetAmount: 1,
        currentAmount: 1,
        rewardType: QuestRewardType.food,
        rewardAmount: 150,
        isCompleted: true,
        isClaimed: false,
      );

      notifier.state = notifier.state.copyWith(
        quests: [completedQuest, ...notifier.state.quests],
      );

      final initialFood = notifier.state.resources.food;
      final success = notifier.claimQuestReward('q_instant');

      expect(success, true);
      expect(notifier.state.resources.food, initialFood + 150);
      expect(notifier.state.quests.first.isClaimed, true);

      // İkinci defa almaya çalışınca false dönmeli
      final secondClaim = notifier.claimQuestReward('q_instant');
      expect(secondClaim, false);

      notifier.dispose();
    });
  });
}
