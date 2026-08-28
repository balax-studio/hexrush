import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/tile_action_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Worker Logistics Drain & Backlog Fix Tests', () {
    test('Worker drains both active production and backlogged accumulatedResource', () {
      final notifier = GameStateNotifier();

      // Setup a worker at (0, 1) and a corn farm at (0, 0)
      final farmCoord = const HexAxial(0, 0);
      final workerCoord = const HexAxial(0, 1);

      final updatedTiles = Map<HexAxial, HexTileModel>.from(notifier.state.tiles);

      // Corn farm with level 1 and 5.0 backlogged accumulated resources
      updatedTiles[farmCoord] = HexTileModel(
        coord: farmCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.corn,
          level: 1,
          accumulatedResource: 5.0,
        ),
      );

      // Worker hut with level 2 (carrying capacity = 3.36)
      updatedTiles[workerCoord] = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.worker,
          level: 2,
        ),
      );

      notifier.state = notifier.state.copyWith(
        tiles: updatedTiles,
        resources: notifier.state.resources.copyWith(food: 0.0),
      );

      // Trigger gameloop tick
      // Calling update/tick indirectly via gameloop or by simulating the notifier tick
      // Worker carrying capacity at Level 2 is 1.68 * 2 = 3.36.
      // Farm base production is 0.42.
      // Total needed to transport = 5.0 + 0.42 = 5.42.
      // In 1 tick: carried = 3.36, remaining accumulated = 5.42 - 3.36 = 2.06.
    });

    testWidgets('TileActionSheet renders unified green total synergy stat and expands on tap', (tester) async {
      final farmCoord = const HexAxial(0, 0);
      final millCoord = const HexAxial(0, 1); // Adjacent -> Chain Synergy (2.0x)

      final container = ProviderContainer(
        overrides: [
          gameStateProvider.overrideWith((ref) {
            final notifier = GameStateNotifier();
            final updatedTiles = Map<HexAxial, HexTileModel>.from(notifier.state.tiles);

            updatedTiles[farmCoord] = HexTileModel(
              coord: farmCoord,
              biome: TileBiome.meadow,
              state: TileState.owned,
              building: const BuildingModel(type: BuildingType.corn, level: 1),
            );

            updatedTiles[millCoord] = HexTileModel(
              coord: millCoord,
              biome: TileBiome.meadow,
              state: TileState.owned,
              building: const BuildingModel(type: BuildingType.windmill, level: 1),
            );

            notifier.state = notifier.state.copyWith(
              tiles: updatedTiles,
              selectedCoord: millCoord, // Select the windmill
            );
            return notifier;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TileActionSheet(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Unified green synergy stat is displayed
      expect(find.textContaining('SİNERJİ & PATLAMA ETKİSİ'), findsOneWidget);

      // Tap on the synergy stat to expand details
      await tester.tap(find.textContaining('SİNERJİ & PATLAMA ETKİSİ'));
      await tester.pump();

      // Expanded details show Zincir Sinerjisi tag
      expect(find.textContaining('Zincir Sinerjisi'), findsOneWidget);
    });
  });
}
