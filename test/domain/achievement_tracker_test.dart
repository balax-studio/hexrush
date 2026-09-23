import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/achievement_tracker.dart';
import 'package:hex_rush/domain/models/achievement_model.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('AchievementModel & Multilingual Catalog Tests', () {
    test('All catalog achievements must have non-empty titles and descriptions in tr, en, es, de', () {
      final catalog = AchievementCatalog.all;
      expect(catalog.length, greaterThanOrEqualTo(20));

      for (final ach in catalog) {
        expect(ach.getTitle('tr'), isNotEmpty, reason: '${ach.id} TR title is empty');
        expect(ach.getTitle('en'), isNotEmpty, reason: '${ach.id} EN title is empty');
        expect(ach.getTitle('es'), isNotEmpty, reason: '${ach.id} ES title is empty');
        expect(ach.getTitle('de'), isNotEmpty, reason: '${ach.id} DE title is empty');

        expect(ach.getDescription('tr'), isNotEmpty, reason: '${ach.id} TR description is empty');
        expect(ach.getDescription('en'), isNotEmpty, reason: '${ach.id} EN description is empty');
        expect(ach.getDescription('es'), isNotEmpty, reason: '${ach.id} ES description is empty');
        expect(ach.getDescription('de'), isNotEmpty, reason: '${ach.id} DE description is empty');

        expect(ach.crownReward, greaterThan(0), reason: '${ach.id} must offer a crown reward');
        expect(ach.targetProgress, greaterThan(0), reason: '${ach.id} target progress must be positive');
      }
    });

    test('AchievementModel JSON serialization and deserialization retains all properties', () {
      const ach = AchievementModel(
        id: 'ach_first_conquest',
        titles: {'tr': 'İlk Otağ', 'en': 'First Outpost'},
        descriptions: {'tr': 'Test', 'en': 'Test'},
        category: AchievementCategory.conquest,
        iconCode: 'flag',
        currentProgress: 1.0,
        targetProgress: 1.0,
        isUnlocked: true,
        unlockedAt: 1700000000,
        crownReward: 15,
        isRewardClaimed: true,
      );

      final json = ach.toJson();
      final deserialized = AchievementModel.fromJson(json);

      expect(deserialized.id, equals('ach_first_conquest'));
      expect(deserialized.isUnlocked, isTrue);
      expect(deserialized.isRewardClaimed, isTrue);
      expect(deserialized.currentProgress, equals(1.0));
      expect(deserialized.unlockedAt, equals(1700000000));
      expect(deserialized.crownReward, equals(15));
    });
  });

  group('AchievementTracker Evaluation Tests', () {
    test('Unlocks conquest achievements as owned tiles increase', () {
      final initialAchievements = AchievementCatalog.getInitialList();
      final Map<HexAxial, HexTileModel> tiles = {
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
        ),
      };

      final state = GameState(
        tiles: tiles,
        achievements: initialAchievements,
      );

      final result = AchievementTracker.evaluate(state);
      final firstConquest = result.updatedAchievements.firstWhere((a) => a.id == 'ach_first_conquest');
      expect(firstConquest.isUnlocked, isTrue);
      expect(result.newlyUnlocked.any((a) => a.id == 'ach_first_conquest'), isTrue);

      final steppeBorders = result.updatedAchievements.firstWhere((a) => a.id == 'ach_steppe_borders');
      expect(steppeBorders.isUnlocked, isFalse);
      expect(steppeBorders.currentProgress, equals(1.0));
    });

    test('Unlocks tier 3 building achievements', () {
      final initialAchievements = AchievementCatalog.getInitialList();
      final Map<HexAxial, HexTileModel> tiles = {
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.forest,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.lumberjack, level: 3),
        ),
        const HexAxial(1, 0): const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.mountain,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.mine, level: 3),
        ),
      };

      final state = GameState(
        tiles: tiles,
        achievements: initialAchievements,
      );

      final result = AchievementTracker.evaluate(state);
      final lumberjackAch = result.updatedAchievements.firstWhere((a) => a.id == 'ach_master_lumberjack');
      final mineAch = result.updatedAchievements.firstWhere((a) => a.id == 'ach_deep_mine');

      expect(lumberjackAch.isUnlocked, isTrue);
      expect(mineAch.isUnlocked, isTrue);
    });

    test('Unlocks winter warm hearth achievement when all buildings are heated in winter', () {
      final initialAchievements = AchievementCatalog.getInitialList();
      final Map<HexAxial, HexTileModel> tiles = {
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
          isWarmed: true,
          warmTimer: 60.0,
        ),
      };

      final state = GameState(
        tiles: tiles,
        season: const SeasonModel(current: 'WINTER'),
        achievements: initialAchievements,
      );

      final result = AchievementTracker.evaluate(state);
      final warmHearth = result.updatedAchievements.firstWhere((a) => a.id == 'ach_warm_hearth');
      expect(warmHearth.isUnlocked, isTrue);
    });
  });
}
