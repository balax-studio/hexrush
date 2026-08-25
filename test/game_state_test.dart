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
      expect(notifier.state.resources.stone, equals(8.0));
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

    test('warm tile consumes wood and sets warmed state', () {
      final notifier = GameStateNotifier();
      const center = HexAxial(0, 0);
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(wood: 10.0),
      );

      final success = notifier.warmTile(center);
      expect(success, isTrue);
      expect(notifier.state.tiles[center]?.isWarmed, isTrue);
      // Başlangıçta aktif olan Kış Otağı doktrini maliyeti 5'ten 2'ye düşürür (10 - 2 = 8)
      expect(notifier.state.resources.wood, equals(8.0));
      notifier.dispose();
    });

    test('watchtower construction reveals surrounding 2-radius fog', () {
      final notifier = GameStateNotifier();
      // Level up castle to 2 to allow watchtower
      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(castleLevel: 2),
        resources: const ResourcesModel(food: 100.0, wood: 100.0),
      );

      const target = HexAxial(1, 0);

      // Force tile biome to meadow for test predictability before conquer
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          target: notifier.state.tiles[target]!.copyWith(biome: TileBiome.meadow),
        },
      );

      notifier.conquerTile(target);

      final built = notifier.buildStructure(target, BuildingType.watchtower);
      expect(built, isTrue);

      // Verify that tiles in radius 2 around (1, 0) are discovered
      const checkCoord = HexAxial(3, 0);
      expect(notifier.state.tiles[checkCoord]?.state, equals(TileState.discovered));
      notifier.dispose();
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
