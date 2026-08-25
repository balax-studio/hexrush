import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Softlock Prevention and Failsafe Tests', () {
    test('Initial map generation guarantees meadow and forest in Radius 1', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;

      const center = HexAxial(0, 0);
      expect(state.tiles[center]?.isOwned, true);
      expect(state.tiles[center]?.building?.type, BuildingType.castle);

      final neighbors = center.neighbors;
      final neighborBiomes = neighbors.map((c) => state.tiles[c]?.biome).toList();

      final meadowCount = neighborBiomes.where((b) => b == TileBiome.meadow).length;
      final forestCount = neighborBiomes.where((b) => b == TileBiome.forest).length;

      // Softlock Prevention: Must have at least 3 meadow tiles and 1 forest tile adjacent to start
      expect(meadowCount, greaterThanOrEqualTo(3));
      expect(forestCount, greaterThanOrEqualTo(1));

      notifier.dispose();
    });

    test('Collecting from Castle provides emergency food rations', () {
      final notifier = GameStateNotifier();
      const center = HexAxial(0, 0);

      // Drain all food to 0 to simulate bankruptcy
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(food: 0.0),
      );
      expect(notifier.state.resources.food, 0.0);

      // Tap castle for emergency rations
      final collected = notifier.collectFromTile(center);
      expect(collected, true);
      expect(notifier.state.resources.food, 1.0);

      // Tap 4 more times
      for (int i = 0; i < 4; i++) {
        notifier.collectFromTile(center);
      }
      expect(notifier.state.resources.food, 5.0);

      notifier.dispose();
    });
  });
}
