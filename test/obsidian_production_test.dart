import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const castleCoord = HexAxial(0, 0);
  const forgeCoord = HexAxial(1, 0);

  final tiles = <HexAxial, HexTileModel>{
    castleCoord: const HexTileModel(
      coord: castleCoord,
      biome: TileBiome.meadow,
      state: TileState.owned,
      building: BuildingModel(type: BuildingType.castle),
    ),
    forgeCoord: const HexTileModel(
      coord: forgeCoord,
      biome: TileBiome.volcano,
      state: TileState.owned,
      building: BuildingModel(type: BuildingType.obsidianForge),
    ),
  };

  test('obsidian forge contributes to the obsidian income rate', () {
    final rates = EconomyCalculator.calculateNetRates(
      tiles: tiles.values,
      tileMap: tiles,
      globalMultiplier: 1.0,
      seasonMultiplier: 1.0,
      shrineMultiplier: 1.0,
    );

    expect(rates.obsidian, greaterThan(0.0));
  });

  test(
    'resource breakdown lists the obsidian forge as an obsidian producer',
    () {
      final breakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'obsidian',
        tiles: tiles,
        castleLevel: 40,
        crowns: 0,
      );

      expect(breakdown.totalProduction, greaterThan(0.0));
      expect(
        breakdown.producers.any(
          (producer) => producer.buildingType == BuildingType.obsidianForge,
        ),
        isTrue,
      );
    },
  );

  test('offline production includes obsidian and its ad boost', () {
    final gains = EconomyCalculator.calculateOfflineGains(
      tiles: tiles.values.toList(),
      elapsedSeconds: 60.0,
      minThresholdSeconds: 1.0,
      globalMultiplier: 1.0,
    );
    final boosted = EconomyCalculator.calculateOfflineAdBoostedGains(gains);

    expect(gains.obsidian, greaterThan(0.0));
    expect(boosted.obsidian, gains.obsidian * 2.0);
  });

  test('one game tick adds transported obsidian to inventory', () {
    final notifier = GameStateNotifier();
    notifier.state = notifier.state.copyWith(tiles: tiles);

    notifier.testTick();

    expect(notifier.state.resources.obsidian, greaterThan(0.0));
    notifier.dispose();
  });
}
