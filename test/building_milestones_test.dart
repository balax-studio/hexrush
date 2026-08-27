import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/tile_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Building Milestones Production and Cost Tests', () {
    test('Building production boosts by 2x at milestone levels 10, 25, 50, 100, 200', () {
      const bType = BuildingType.corn;
      final b1 = BuildingModel(type: bType, level: 1);
      final b9 = BuildingModel(type: bType, level: 9);
      final b10 = BuildingModel(type: bType, level: 10);
      final b24 = BuildingModel(type: bType, level: 24);
      final b25 = BuildingModel(type: bType, level: 25);
      final b49 = BuildingModel(type: bType, level: 49);
      final b50 = BuildingModel(type: bType, level: 50);
      final b99 = BuildingModel(type: bType, level: 99);
      final b100 = BuildingModel(type: bType, level: 100);
      final b199 = BuildingModel(type: bType, level: 199);
      final b200 = BuildingModel(type: bType, level: 200);

      final base = b1.baseProductionRate;

      // Level 1: base * 1 * 2^0
      expect(b1.currentProductionRate, closeTo(base * 1, 0.001));

      // Level 9: base * 9 * 2^0
      expect(b9.currentProductionRate, closeTo(base * 9, 0.001));

      // Level 10: base * 10 * 2^1 (2x boost)
      expect(b10.currentProductionRate, closeTo(base * 10 * 2, 0.001));

      // Level 24: base * 24 * 2^1
      expect(b24.currentProductionRate, closeTo(base * 24 * 2, 0.001));

      // Level 25: base * 25 * 2^2 (4x total milestone boost)
      expect(b25.currentProductionRate, closeTo(base * 25 * 4, 0.001));

      // Level 50: base * 50 * 2^3 (8x total milestone boost)
      expect(b50.currentProductionRate, closeTo(base * 50 * 8, 0.001));

      // Level 100: base * 100 * 2^4 (16x total milestone boost)
      expect(b100.currentProductionRate, closeTo(base * 100 * 16, 0.001));

      // Level 200: base * 200 * 2^5 (32x total milestone boost)
      expect(b200.currentProductionRate, closeTo(base * 200 * 32, 0.001));
    });

    test('Upgrade cost increases by 10x normal rate at milestone steps', () {
      const bType = BuildingType.corn;
      final b8 = BuildingModel(type: bType, level: 8);
      final b9 = BuildingModel(type: bType, level: 9);
      final b10 = BuildingModel(type: bType, level: 10);
      final b23 = BuildingModel(type: bType, level: 23);
      final b24 = BuildingModel(type: bType, level: 24);
      final b25 = BuildingModel(type: bType, level: 25);

      final cost8 = b8.upgradeCost;
      final cost9 = b9.upgradeCost;
      final cost10 = b10.upgradeCost;

      // 8 -> 9 to 9 -> 10 transition has an extra 10x factor (1.15 * 10 = 11.5)
      final ratio9to10 = cost9 / cost8;
      expect(ratio9to10, closeTo(1.15 * 10.0, 0.01));

      // 9 -> 10 to 10 -> 11 transition resumes normal 1.15 rate
      final ratio10to11 = cost10 / cost9;
      expect(ratio10to11, closeTo(1.15, 0.01));

      // 23 -> 24 to 24 -> 25 transition has an extra 10x factor
      final cost23 = b23.upgradeCost;
      final cost24 = b24.upgradeCost;
      final ratio24to25 = cost24 / cost23;
      expect(ratio24to25, closeTo(1.15 * 10.0, 0.01));
    });

    test('isNextLevelMilestone correctly identifies levels 9, 24, 49, 99, 199', () {
      expect(BuildingModel(type: BuildingType.corn, level: 1).isNextLevelMilestone, isFalse);
      expect(BuildingModel(type: BuildingType.corn, level: 9).isNextLevelMilestone, isTrue);
      expect(BuildingModel(type: BuildingType.corn, level: 10).isNextLevelMilestone, isFalse);
      expect(BuildingModel(type: BuildingType.corn, level: 24).isNextLevelMilestone, isTrue);
      expect(BuildingModel(type: BuildingType.corn, level: 49).isNextLevelMilestone, isTrue);
      expect(BuildingModel(type: BuildingType.corn, level: 99).isNextLevelMilestone, isTrue);
      expect(BuildingModel(type: BuildingType.corn, level: 199).isNextLevelMilestone, isTrue);
    });

    test('EconomyCalculator calculates building production matching milestone boosts', () {
      final rateLvl1 = EconomyCalculator.calculateBuildingProduction(
        type: BuildingType.corn,
        level: 1,
        baseRate: 0.42,
      );
      final rateLvl10 = EconomyCalculator.calculateBuildingProduction(
        type: BuildingType.corn,
        level: 10,
        baseRate: 0.42,
      );

      // Level 10 should be 10 * 2 = 20 times level 1
      expect(rateLvl10 / rateLvl1, closeTo(20.0, 0.001));
    });
  });

  group('TileActionSheet Milestone UI Widget Tests', () {
    testWidgets('TileActionSheet shows 2X GELİR and milestone badge when level is 9', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testCoord = const HexAxial(0, 1);
      final tile = HexTileModel(
        coord: testCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 9),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) {
              final notifier = GameStateNotifier();
              notifier.state = notifier.state.copyWith(
                selectedCoord: testCoord,
                tiles: {
                  ...notifier.state.tiles,
                  testCoord: tile,
                },
                resources: notifier.state.resources.copyWith(
                  food: 100000.0,
                  wood: 100000.0,
                ),
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TileActionSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Milestone badge is present
      expect(find.textContaining('2X GELİR KİLOMETRE TAŞI (SEVİYE 10)'), findsOneWidget);

      // Verify Button text contains 2X GELİR
      expect(find.textContaining('2X GELİR'), findsWidgets);
    });
  });
}
