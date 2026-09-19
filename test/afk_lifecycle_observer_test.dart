import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/data/save_repository.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/screens/game_screen.dart';
import 'package:hex_rush/presentation/widgets/offline_gains_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AFK Lifecycle & Offline Revenue Tests', () {
    test('SaveRepository stores and retrieves last active timestamp in milliseconds', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await SaveRepository.saveLastActiveTimestamp(nowMs);

      final retrieved = await SaveRepository.getLastActiveTimestamp();
      expect(retrieved, equals(nowMs));
    });

    test('EconomyCalculator respects 60s minimum threshold and 8h (28800s) maximum cap', () {
      final tiles = [
        const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker),
        ),
      ];

      // 1. Durations < 60s return 0 gains (hasGains == false)
      final sub60Gains = EconomyCalculator.calculateOfflineGains(
        tiles: tiles,
        elapsedSeconds: 59.0,
        globalMultiplier: 1.0,
      );
      expect(sub60Gains.hasGains, isFalse);
      expect(sub60Gains.seconds, equals(0));

      // 2. Exact 60s triggers gains
      final exact60Gains = EconomyCalculator.calculateOfflineGains(
        tiles: tiles,
        elapsedSeconds: 60.0,
        globalMultiplier: 1.0,
      );
      expect(exact60Gains.hasGains, isTrue);
      expect(exact60Gains.seconds, equals(60));
      expect(exact60Gains.food, closeTo(0.42 * 60.0, 0.01));

      // 3. 10 hours (36000s) is capped at 8 hours (28800s with golden retention formula)
      final cappedGains = EconomyCalculator.calculateOfflineGains(
        tiles: tiles,
        elapsedSeconds: 36000.0,
        globalMultiplier: 1.0,
      );
      final eightHoursGains = EconomyCalculator.calculateOfflineGains(
        tiles: tiles,
        elapsedSeconds: 28800.0,
        globalMultiplier: 1.0,
      );
      expect(cappedGains.seconds, equals(eightHoursGains.seconds));
      expect(cappedGains.food, closeTo(eightHoursGains.food, 0.001));
    });

    test('pauseGameLoop saves timestamp to SharedPreferences and stops loops', () async {
      final container = ProviderContainer();
      final notifier = container.read(gameStateProvider.notifier);

      final beforeMs = DateTime.now().millisecondsSinceEpoch;
      notifier.pauseGameLoop();
      final afterMs = DateTime.now().millisecondsSinceEpoch;

      final savedTimestamp = await SaveRepository.getLastActiveTimestamp();
      expect(savedTimestamp, isNotNull);
      expect(savedTimestamp! >= beforeMs && savedTimestamp <= afterMs, isTrue);

      container.dispose();
    });

    test('resumeGameLoop with duration < 60s does not set pendingOfflineGains', () async {
      final container = ProviderContainer();
      final notifier = container.read(gameStateProvider.notifier);

      notifier.pauseGameLoop();
      // Resume immediately (elapsed ~0 seconds < 60s)
      await notifier.resumeGameLoop();

      expect(container.read(gameStateProvider).pendingOfflineGains, isNull);
      container.dispose();
    });

    test('resumeGameLoop with duration >= 60s sets pendingOfflineGains and prevents double-claiming', () async {
      final container = ProviderContainer();
      final notifier = container.read(gameStateProvider.notifier);

      // Add a production building to the state
      notifier.debugModifyState((s) {
        final tiles = Map<HexAxial, HexTileModel>.from(s.tiles);
        tiles[const HexAxial(1, 0)] = const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        );
        return s.copyWith(tiles: tiles);
      });

      // Simulate pausing 120 seconds ago
      final pastMs = DateTime.now().millisecondsSinceEpoch - 120000;
      await SaveRepository.saveLastActiveTimestamp(pastMs);

      await notifier.resumeGameLoop();

      final pending = container.read(gameStateProvider).pendingOfflineGains;
      expect(pending, isNotNull);
      expect(pending!.hasGains, isTrue);
      expect(pending.seconds, greaterThanOrEqualTo(119));

      // Double-claiming test: immediate subsequent resume should not award again
      await notifier.resumeGameLoop();
      // The pending gains should not change to a new 120s gain, or if cleared, remain null
      final lastActive = await SaveRepository.getLastActiveTimestamp();
      expect(lastActive, isNotNull);
      final diff = DateTime.now().millisecondsSinceEpoch - lastActive!;
      expect(diff, lessThan(5000));

      container.dispose();
    });

    test('Cold boot initialize() computes AFK gains from stored timestamp and prevents double-claiming', () async {
      // Setup saved state with a worker and corn field saved 10 minutes (600s) ago
      final pastTimeSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 600;
      final pastTimeMs = pastTimeSeconds * 1000;

      await SaveRepository.saveGame(
        resources: const ResourcesModel(food: 100, wood: 50),
        progression: const ProgressionModel(castleLevel: 1, ownedCount: 2),
        season: const SeasonModel(),
        settings: const SettingsModel(),
        tiles: [
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
          const HexTileModel(
            coord: HexAxial(2, 0),
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.worker),
          ),
        ],
      );
      await SaveRepository.saveLastActiveTimestamp(pastTimeMs);

      final container = ProviderContainer();
      final notifier = container.read(gameStateProvider.notifier);
      await notifier.initialize();

      final pending = container.read(gameStateProvider).pendingOfflineGains;
      expect(pending, isNotNull);
      expect(pending!.hasGains, isTrue);
      expect(pending.food, greaterThan(0));

      // Check that lastActiveTimestamp was updated to current time (double-claim guard)
      final updatedLastActive = await SaveRepository.getLastActiveTimestamp();
      expect(updatedLastActive, isNotNull);
      expect(updatedLastActive! > pastTimeMs, isTrue);

      container.dispose();
    });

    testWidgets('WidgetsBindingObserver lifecycle triggers dialog on resume in GameScreen', (tester) async {
      // Setup saved game with production building
      final pastTimeSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 300;
      final pastMs = pastTimeSeconds * 1000;

      await SaveRepository.saveGame(
        resources: const ResourcesModel(food: 100, wood: 50),
        progression: const ProgressionModel(castleLevel: 1, ownedCount: 2),
        season: const SeasonModel(),
        settings: const SettingsModel(),
        tiles: [
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
        ],
      );
      await SaveRepository.saveLastActiveTimestamp(pastMs);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate AppLifecycleState.resumed
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Offline gains popup should be displayed
      expect(find.byType(OfflineGainsDialog), findsOneWidget);
      expect(find.text('BOZKIR ÇEVRİMDIŞI KAZANCI'), findsOneWidget);
      expect(find.text('TOPLA'), findsOneWidget);

      // Tapping TOPLA collects gains and closes dialog
      await tester.tap(find.text('TOPLA'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OfflineGainsDialog), findsNothing);
    });
  });
}
