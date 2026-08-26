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

  group('Kağan Otağı (Castle) Level Synchronization Tests', () {
    test('upgradeCastle upgrades progression.castleLevel and updates tile building level', () {
      final notifier = GameStateNotifier();

      // Give enough resources for castle upgrade
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 5000.0, wood: 5000.0),
      );

      final initialLevel = notifier.state.progression.castleLevel;
      final castleCoord = notifier.state.tiles.entries
          .firstWhere((e) => e.value.building?.type == BuildingType.castle)
          .key;

      expect(notifier.state.tiles[castleCoord]!.building!.level, equals(initialLevel));

      // Upgrade castle
      final bool success = notifier.upgradeCastle();
      expect(success, isTrue);

      final newLevel = initialLevel + 1;
      expect(notifier.state.progression.castleLevel, equals(newLevel));
      expect(notifier.state.tiles[castleCoord]!.building!.level, equals(newLevel));
    });

    test('upgradeBuilding on castle coordinate triggers upgradeCastle', () {
      final notifier = GameStateNotifier();

      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 5000.0, wood: 5000.0),
      );

      final castleCoord = notifier.state.tiles.entries
          .firstWhere((e) => e.value.building?.type == BuildingType.castle)
          .key;

      final initialLevel = notifier.state.progression.castleLevel;
      final bool success = notifier.upgradeBuilding(castleCoord);
      expect(success, isTrue);

      expect(notifier.state.progression.castleLevel, equals(initialLevel + 1));
      expect(notifier.state.tiles[castleCoord]!.building!.level, equals(initialLevel + 1));
    });

    test('multiple upgrades to level 10 keep castle tile synchronized', () {
      final notifier = GameStateNotifier();

      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 100000.0, wood: 100000.0),
      );

      final castleCoord = notifier.state.tiles.entries
          .firstWhere((e) => e.value.building?.type == BuildingType.castle)
          .key;

      for (int i = 1; i < 10; i++) {
        final ok = notifier.upgradeCastle();
        expect(ok, isTrue);
      }

      expect(notifier.state.progression.castleLevel, equals(10));
      expect(notifier.state.tiles[castleCoord]!.building!.level, equals(10));
    });
  });
}
