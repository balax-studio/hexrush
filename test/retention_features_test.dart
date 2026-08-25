import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/migrant_memory_dialog.dart';
import 'package:hex_rush/presentation/widgets/season_calendar_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Biome Mastery & Economy Tests', () {
    test('getBiomeMasteryMultiplier computes accurate bonuses', () {
      expect(
        EconomyCalculator.getBiomeMasteryMultiplier(
          biome: TileBiome.meadow,
          cumulativeBiomeCounts: {'meadow': 2},
        ),
        1.0,
      );

      expect(
        EconomyCalculator.getBiomeMasteryMultiplier(
          biome: TileBiome.meadow,
          cumulativeBiomeCounts: {'meadow': 5},
        ),
        1.05,
      );

      expect(
        EconomyCalculator.getBiomeMasteryMultiplier(
          biome: TileBiome.forest,
          cumulativeBiomeCounts: {'forest': 12},
        ),
        1.10,
      );
    });

    test('calculateBuildingProduction applies biome mastery multiplier', () {
      final baseProd = EconomyCalculator.calculateBuildingProduction(
        type: BuildingType.corn,
        level: 1,
        baseRate: 2.0,
        biomeMasteryMultiplier: 1.05,
      );
      expect(baseProd, closeTo(2.10, 0.001));
    });

    test('calculateNetRates integrates biome mastery multiplier across tiles', () {
      const tile = HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.corn,
          level: 1,
        ),
      );

      final rates = EconomyCalculator.calculateNetRates(
        tiles: [tile],
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
        season: 'SUMMER',
        cumulativeBiomeCounts: {'meadow': 5},
      );

      // Corn baseProductionRate is 0.42. With 1.05 mastery multiplier -> 0.441
      expect(rates.food, closeTo(0.441, 0.001));
    });
  });

  group('Data Models & Serialization Tests', () {
    test('MigrationRecordModel serialization round-trip', () {
      const record = MigrationRecordModel(
        migrationNumber: 2,
        ownedCount: 15,
        tamgasGained: 7,
        zudCount: 3,
        topSynergy: 'Volkan-Maden',
        doctrinesUsed: ['doc_1', 'doc_2'],
        timestamp: '2026-08-25T12:00:00Z',
      );

      final json = record.toJson();
      final fromJson = MigrationRecordModel.fromJson(json);

      expect(fromJson.migrationNumber, 2);
      expect(fromJson.ownedCount, 15);
      expect(fromJson.tamgasGained, 7);
      expect(fromJson.zudCount, 3);
      expect(fromJson.topSynergy, 'Volkan-Maden');
      expect(fromJson.doctrinesUsed, ['doc_1', 'doc_2']);
      expect(fromJson.timestamp, '2026-08-25T12:00:00Z');
    });

    test('NotificationSettingsModel serialization round-trip', () {
      const notif = NotificationSettingsModel(
        storageFullAlert: true,
        seasonChangeAlert: true,
        questCompletedAlert: false,
        castleUpgradeReadyAlert: true,
      );

      final json = notif.toJson();
      final fromJson = NotificationSettingsModel.fromJson(json);

      expect(fromJson.storageFullAlert, isTrue);
      expect(fromJson.seasonChangeAlert, isTrue);
      expect(fromJson.questCompletedAlert, isFalse);
      expect(fromJson.castleUpgradeReadyAlert, isTrue);
    });

    test('ProgressionModel serialization preserves history and biome counts', () {
      const prog = ProgressionModel(
        castleLevel: 3,
        ownedCount: 12,
        totalMigrations: 2,
        migrationHistory: [
          MigrationRecordModel(
            migrationNumber: 1,
            ownedCount: 10,
            tamgasGained: 5,
            timestamp: '2026-08-25T10:00:00Z',
          ),
        ],
        cumulativeBiomeCounts: {'meadow': 7, 'mountain': 4},
      );

      final json = prog.toJson();
      final fromJson = ProgressionModel.fromJson(json);

      expect(fromJson.castleLevel, 3);
      expect(fromJson.ownedCount, 12);
      expect(fromJson.totalMigrations, 2);
      expect(fromJson.migrationHistory.length, 1);
      expect(fromJson.migrationHistory.first.migrationNumber, 1);
      expect(fromJson.cumulativeBiomeCounts['meadow'], 7);
      expect(fromJson.cumulativeBiomeCounts['mountain'], 4);
    });
  });

  group('GameStateNotifier Retention & Migration Tests', () {
    test('conquerTile updates cumulativeBiomeCounts', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);

      // Force target biome to meadow to avoid level lock flakiness
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 1000.0),
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
        },
      );

      final success = notifier.conquerTile(target);
      expect(success, isTrue);
      final newCount = notifier.state.progression.cumulativeBiomeCounts['meadow'] ?? 0;
      expect(newCount, greaterThanOrEqualTo(1));
      notifier.dispose();
    });

    test('resetGame records migration history and preserves cumulative biomes', () {
      final notifier = GameStateNotifier();
      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(
          ownedCount: 10,
          cumulativeBiomeCounts: {'meadow': 8, 'forest': 5},
        ),
      );

      expect(notifier.state.progression.migrationHistory.isEmpty, isTrue);
      notifier.resetGame();

      expect(notifier.state.progression.totalMigrations, 1);
      expect(notifier.state.progression.migrationHistory.length, 1);
      expect(notifier.state.progression.migrationHistory.first.migrationNumber, 1);
      expect(notifier.state.progression.cumulativeBiomeCounts['meadow'], 8);
      expect(notifier.state.progression.cumulativeBiomeCounts['forest'], 5);
      notifier.dispose();
    });

    test('updateNotificationSettings toggles preferences and persists state', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.settings.notifications.storageFullAlert, isFalse);

      notifier.updateNotificationSettings(storageFullAlert: true, seasonChangeAlert: true);
      expect(notifier.state.settings.notifications.storageFullAlert, isTrue);
      expect(notifier.state.settings.notifications.seasonChangeAlert, isTrue);
      expect(notifier.state.settings.notifications.questCompletedAlert, isFalse);
      notifier.dispose();
    });
  });

  group('Widget Tests: SeasonCalendar & MigrantMemory', () {
    testWidgets('SeasonCalendarWidget renders all 4 seasons and countdowns', (tester) async {
      const season = SeasonModel(
        current: 'SPRING',
        timer: 120.0,
        year: 1,
        isZud: false,
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

      expect(find.textContaining('MEVSİM TAKVİMİ'), findsOneWidget);
      expect(find.textContaining('180sn'), findsOneWidget); // 300 - 120 = 180s
      expect(find.text('BAHAR'), findsOneWidget);
      expect(find.text('YAZ'), findsOneWidget);
      expect(find.text('SONBAHAR'), findsOneWidget);
      expect(find.text('KIŞ'), findsOneWidget);
    });

    testWidgets('MigrantMemoryDialog renders migration statistics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) {
              final notifier = GameStateNotifier();
              notifier.state = notifier.state.copyWith(
                progression: notifier.state.progression.copyWith(
                  totalMigrations: 1,
                  migrationHistory: const [
                    MigrationRecordModel(
                      migrationNumber: 1,
                      ownedCount: 14,
                      tamgasGained: 6,
                      zudCount: 2,
                      topSynergy: 'Bozkır Düzeni',
                      timestamp: '2026-08-25T12:00:00Z',
                    ),
                  ],
                ),
                resources: notifier.state.resources.copyWith(tamgas: 6),
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MigrantMemoryDialog(),
            ),
          ),
        ),
      );

      expect(find.text('GÖÇMEN HAFIZASI'), findsOneWidget);
      expect(find.text('TOPLAM GÖÇ'), findsOneWidget);
      expect(find.text('TAMGA SAYISI'), findsOneWidget);
      expect(find.textContaining('1. BÜYÜK GÖÇ'), findsOneWidget);
      expect(find.textContaining('+6 Tamga'), findsOneWidget);
      expect(find.textContaining('Fethedilen: 14 Karo'), findsOneWidget);
    });
  });
}
