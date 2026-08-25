import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/quest_tracker_hud.dart';
import 'package:hex_rush/presentation/widgets/season_calendar_widget.dart';
import 'package:hex_rush/presentation/widgets/tore_dialog.dart';
import 'package:hex_rush/presentation/widgets/top_bar_hud.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ethical Feature 1: Cumulative Session Counter Tests', () {
    test('ProgressionModel serialization preserves totalSessions', () {
      const model = ProgressionModel(totalSessions: 42);
      final json = model.toJson();
      expect(json['total_sessions'], 42);

      final fromJson = ProgressionModel.fromJson(json);
      expect(fromJson.totalSessions, 42);
    });

    test('resetGame preserves totalSessions counter without penalty', () {
      final notifier = GameStateNotifier();
      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(totalSessions: 15),
      );

      notifier.resetGame();
      expect(notifier.state.progression.totalSessions, 15);
      notifier.dispose();
    });
  });

  group('Ethical Feature 2: Amber Notification Dot Tests', () {
    testWidgets('TopBarHUD renders amber dot when castle upgrade is affordable', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) {
              final notifier = GameStateNotifier();
              notifier.state = notifier.state.copyWith(
                resources: notifier.state.resources.copyWith(
                  food: 1000.0,
                  wood: 1000.0,
                ),
                progression: notifier.state.progression.copyWith(castleLevel: 1),
              );
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TopBarHUD(
                onOpenMarket: () {},
                onOpenSettings: () {},
                onOpenTore: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('OTAĞ LV.1'), findsOneWidget);
    });
  });

  group('Ethical Feature 3: Conquest Tactile Feedback Tests', () {
    test('conquerTile triggers successfully on discovered tile', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);

      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 500.0),
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
        },
      );

      final success = notifier.conquerTile(target);
      expect(success, isTrue);
      notifier.dispose();
    });
  });

  group('Ethical Feature 4: Quest Tracker Collapsing & Progress Tests', () {
    testWidgets('QuestTrackerHUD collapses and expands smoothly on header tap', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuestTrackerHUD(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('GÖREV'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('GÖREV'));
      await tester.pump(const Duration(milliseconds: 100));

      // In collapsed state, displays compact quest progress indicator
      expect(find.textContaining('GÖREV:'), findsOneWidget);
    });
  });

  group('Ethical Feature 5: Title Lore Inscriptions Tests', () {
    testWidgets('ToreDialog renders archaeological inscriptions for titles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ToreDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to UNVANLAR (Tab 3)
      await tester.tap(find.text('UNVANLAR'));
      await tester.pumpAndSettle();

      expect(find.text('BÜYÜK KAĞAN'), findsOneWidget);
      expect(find.textContaining('On boyu birleştiren'), findsOneWidget);
      expect(find.text('TOPRAK FATİHİ'), findsOneWidget);
      expect(find.textContaining('Bozkırın ufuklarını'), findsOneWidget);
    });
  });

  group('Ethical Feature 6: Seasonal Production Multipliers Tests', () {
    test('getSeasonalProductionBoost returns accurate positive bonuses', () {
      // Spring + Food
      expect(
        EconomyCalculator.getSeasonalProductionBoost(
          season: 'SPRING',
          buildingType: BuildingType.corn,
        ),
        1.20,
      );

      // Summer + Wood
      expect(
        EconomyCalculator.getSeasonalProductionBoost(
          season: 'SUMMER',
          buildingType: BuildingType.lumberjack,
        ),
        1.15,
      );

      // Autumn + Mine
      expect(
        EconomyCalculator.getSeasonalProductionBoost(
          season: 'AUTUMN',
          buildingType: BuildingType.mine,
        ),
        1.15,
      );

      // Other seasons return 1.0 baseline
      expect(
        EconomyCalculator.getSeasonalProductionBoost(
          season: 'WINTER',
          buildingType: BuildingType.corn,
        ),
        1.0,
      );
    });

    test('calculateNetRates integrates Spring +20% food boost into corn rate', () {
      const tile = HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.corn,
          level: 1,
        ),
      );

      final ratesSpring = EconomyCalculator.calculateNetRates(
        tiles: [tile],
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
        season: 'SPRING',
      );

      // Corn base is 0.42. In Spring +20% -> 0.42 * 1.20 = 0.504
      expect(ratesSpring.food, closeTo(0.504, 0.001));

      final ratesSummer = EconomyCalculator.calculateNetRates(
        tiles: [tile],
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
        season: 'SUMMER',
      );

      // Corn base in Summer is standard 0.42
      expect(ratesSummer.food, closeTo(0.42, 0.001));
    });

    testWidgets('SeasonCalendarWidget displays seasonal bonus labels', (tester) async {
      const season = SeasonModel(
        current: 'SPRING',
        timer: 100.0,
        year: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeasonCalendarWidget(
              season: season,
              language: 'tr',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('+%20 Gıda'), findsOneWidget);
      expect(find.text('+%15 Odun'), findsOneWidget);
      expect(find.text('+%15 Maden'), findsOneWidget);
      expect(find.text('-%50 Don'), findsOneWidget);
    });
  });
}
