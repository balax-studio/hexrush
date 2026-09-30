import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameStateNotifier Tests', () {
    test('initializes with center castle tile and discovered neighbors', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;

      expect(state.tiles.containsKey(const HexAxial(0, 0)), isTrue);
      final center = state.tiles[const HexAxial(0, 0)]!;
      expect(center.state, equals(TileState.owned));
      expect(center.building?.type, equals(BuildingType.castle));

      // Neighbors should be discovered
      for (final n in const HexAxial(0, 0).neighbors) {
        expect(state.tiles[n]?.state, equals(TileState.discovered));
      }
      notifier.dispose();
    });

    test('conquering adjacent discovered tile succeeds when affordable', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);

      // Force target biome to meadow to avoid level lock flakiness
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
        },
      );

      final success = notifier.conquerTile(target);
      expect(success, isTrue);
      expect(notifier.state.tiles[target]?.state, equals(TileState.owned));
      expect(notifier.state.progression.ownedCount, equals(2));
      notifier.dispose();
    });

    test('building structure on owned tile updates tile and deducts resource', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);

      notifier.conquerTile(target);
      if (notifier.state.tiles[target]?.biome == TileBiome.meadow) {
        final built = notifier.buildStructure(target, BuildingType.corn);
        expect(built, isTrue);
        expect(notifier.state.tiles[target]?.building?.type, equals(BuildingType.corn));
      }
      notifier.dispose();
    });

    test('market trade successfully swaps flour for stone', () {
      final notifier = GameStateNotifier();
      // Give player flour
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(flour: 30.0, stone: 0.0),
      );

      final success = notifier.executeMarketTrade('flour_to_stone');
      expect(success, isTrue);
      expect(notifier.state.resources.flour, equals(15.0));
      expect(notifier.state.resources.stone, equals(10.0));
      notifier.dispose();
    });

    test('tore talent upgrade consumes crowns and updates talent level', () {
      final notifier = GameStateNotifier();
      // Give player crowns
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(crowns: 5),
      );

      final success = notifier.upgradeToreTalent('gokTengri', 'rainBlessing', 1);
      expect(success, isTrue);
      expect(notifier.state.resources.crowns, equals(4));
      final lvl = notifier.state.toreTalents['gokTengri']?['rainBlessing'];
      expect(lvl, equals(1));
      notifier.dispose();
    });

    test('claiming title unlocks title when criteria met', () {
      final notifier = GameStateNotifier();
      // Set criteria for merchant: 50 flour and 50 plank
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(flour: 60.0, plank: 60.0),
      );

      final success = notifier.claimTitle('merchant');
      expect(success, isTrue);
      expect(notifier.state.titles['merchant'], isTrue);
      notifier.dispose();
    });

    test('warm tile sets warmed state and tick consumes per-second wood', () {
      final notifier = GameStateNotifier();
      const center = HexAxial(0, 0);
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(wood: 10.0),
        season: notifier.state.season.copyWith(current: 'WINTER'),
      );

      final success = notifier.warmTile(center);
      expect(success, isTrue);
      expect(notifier.state.tiles[center]?.isWarmed, isTrue);
      notifier.dispose();
    });

    test('watchtower construction reveals fog within six hexes', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);
      const checkCoord = HexAxial(7, 0);
      const outsideCoord = HexAxial(8, 0);

      // Gözcü Kulesi için Şato Seviye 5 gereklidir
      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(castleLevel: 5),
        resources: const ResourcesModel(food: 200.0, wood: 100.0),
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
          checkCoord: notifier.state.tiles[checkCoord]!.copyWith(state: TileState.fog),
          outsideCoord: notifier.state.tiles[outsideCoord]!.copyWith(state: TileState.fog),
        },
      );

      final conquered = notifier.conquerTile(target);
      expect(conquered, isTrue);

      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(castleLevel: 5),
      );

      final built = notifier.buildStructure(target, BuildingType.watchtower);
      expect(built, isTrue);

      // (7, 0) is six hexes away; (8, 0) is outside the reveal radius.
      expect(notifier.state.tiles[checkCoord]?.state, equals(TileState.discovered));
      expect(notifier.state.tiles[outsideCoord]?.state, equals(TileState.fog));

      final upgraded = notifier.upgradeBuilding(target);
      expect(upgraded, isTrue);
      expect(notifier.state.tiles[outsideCoord]?.state, equals(TileState.discovered));
      notifier.dispose();
    });

    test('limited castle capacity transports food and kumis in the same tick', () {
      final notifier = GameStateNotifier();
      const castleCoord = HexAxial(0, 0);
      const cornCoord = HexAxial(1, 0);
      const kumisCoord = HexAxial(2, 0);
      notifier.state = notifier.state.copyWith(
        tiles: {
          castleCoord: const HexTileModel(
            coord: castleCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.castle),
          ),
          cornCoord: const HexTileModel(
            coord: cornCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.corn),
          ),
          kumisCoord: const HexTileModel(
            coord: kumisCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.kumisYurt),
          ),
        },
        resources: const ResourcesModel(food: 100.0),
      );

      notifier.testTick();

      expect(notifier.state.resources.food, greaterThan(100.0));
      expect(notifier.state.resources.kumis, greaterThan(0.0));
      notifier.dispose();
    });

    test('ancestral production does not get a second migration-only multiplier', () {
      const castleCoord = HexAxial(0, 0);
      const totemCoord = HexAxial(1, 0);
      final tiles = <HexAxial, HexTileModel>{
        castleCoord: const HexTileModel(
          coord: castleCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle),
        ),
        totemCoord: const HexTileModel(
          coord: totemCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.ancestralTotem),
        ),
      };

      GameStateNotifier createNotifier(int totalMigrations) {
        final notifier = GameStateNotifier();
        notifier.state = notifier.state.copyWith(
          tiles: tiles,
          resources: const ResourcesModel(
            food: 100.0,
            wood: 100.0,
            stone: 100.0,
          ),
          progression: notifier.state.progression.copyWith(
            totalMigrations: totalMigrations,
            kutMultiplier: 1.0,
          ),
        );
        return notifier;
      }

      final noMigration = createNotifier(0);
      final afterMigrations = createNotifier(10);
      noMigration.testTick();
      afterMigrations.testTick();

      expect(
        afterMigrations.state.resources.food,
        closeTo(noMigration.state.resources.food, 0.0001),
      );
      expect(
        afterMigrations.state.resources.wood,
        closeTo(noMigration.state.resources.wood, 0.0001),
      );
      noMigration.dispose();
      afterMigrations.dispose();
    });

    test('demolishBuilding clears building and refunds 50% food cost', () {
      final notifier = GameStateNotifier();
      const target = HexAxial(1, 0);

      notifier.state = notifier.state.copyWith(
        resources: const ResourcesModel(food: 100.0),
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
        },
      );

      notifier.conquerTile(target);
      notifier.buildStructure(target, BuildingType.corn);
      expect(notifier.state.tiles[target]?.hasBuilding, isTrue);

      final initialFood = notifier.state.resources.food;
      final demolished = notifier.demolishBuilding(target);
      expect(demolished, isTrue);
      expect(notifier.state.tiles[target]?.hasBuilding, isFalse);
      expect(notifier.state.resources.food, greaterThan(initialFood));
      notifier.dispose();
    });

    test('resetGame prestige migration increments totalMigrations counter', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.progression.totalMigrations, 0);

      notifier.resetGame();
      expect(notifier.state.progression.totalMigrations, 1);

      notifier.resetGame();
      expect(notifier.state.progression.totalMigrations, 2);
      notifier.dispose();
    });
  });
}
