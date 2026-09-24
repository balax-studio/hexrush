import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initial Shrine Placement Tests', () {
    test('r=1, r=2 ve r=3 halkalarında tapınak bulunmaz, dist=4 halkasında 1 garantili speedBoost Kadim Sunak yer alır', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;

      // 1. r=1, r=2 ve r=3 halkalarında tapınak olmadığını doğrula
      const center = HexAxial(0, 0);
      state.tiles.forEach((coord, tile) {
        final dist = HexMath.hexDistance(center, coord);
        if (dist >= 1 && dist <= 3) {
          expect(tile.hasShrine, isFalse,
              reason: 'r=$dist halkasındaki $coord karosunda tapınak bulunmamalıdır');
        }
      });

      // 2. dist=4 halkasındaki garantili speedBoost tapınak kontrolü
      final dist4Shrines = state.tiles.values.where((t) {
        final dist = HexMath.hexDistance(center, t.coord);
        return dist == 4 && t.hasShrine;
      }).toList();

      expect(dist4Shrines, isNotEmpty,
          reason: 'Şatoya 4 hex mesafede en az 1 garantili Kadim Sunak bulunmalıdır');
      final hasSpeedShrine = dist4Shrines.any((t) => t.shrine == ShrineType.speedBoost);
      expect(hasSpeedShrine, isTrue,
          reason: 'Şatoya 4 hex uzaktaki garantili sunaklar arasında Lojistik & Taşıma Bonusu (speedBoost) bulunmalıdır');
      final firstShrine = dist4Shrines.firstWhere((t) => t.shrine == ShrineType.speedBoost);
      expect(firstShrine.state, equals(TileState.discovered),
          reason: '4-hex menzilindeki başlangıç tapınağı görünür (discovered) olmalıdır');

      // 3. Haritada toplam 11 adet Kutlu Tapınak olduğunu doğrula
      final totalShrines = state.tiles.values.where((t) => t.hasShrine).length;
      expect(totalShrines, equals(11),
          reason: 'Harita genelinde toplam 11 adet kutlu tapınak dengesi korunmalıdır');
    });

    test('dist=4 speedBoost tapınağı fethedildiğinde mesafe orantılı bonus devreye girer', () {
      final notifier = GameStateNotifier();
      const center = HexAxial(0, 0);

      final dist4Shrine = notifier.state.tiles.values.firstWhere(
        (t) => HexMath.hexDistance(center, t.coord) == 4 && t.shrine == ShrineType.speedBoost,
      );

      final initialMultiplier = notifier.state.shrineMultiplier;
      expect(initialMultiplier, equals(1.0));

      // Tapınağın bir komşusunu sahip olunan yaparak sınır komşuluk şartını sağla
      final neighbor = dist4Shrine.coord.neighbors.first;
      notifier.state = notifier.state.copyWith(
        tiles: {
          ...notifier.state.tiles,
          neighbor: (notifier.state.tiles[neighbor] ??
                  HexTileModel(
                    coord: neighbor,
                    biome: TileBiome.meadow,
                    state: TileState.discovered,
                  ))
              .copyWith(state: TileState.owned),
        },
        resources: notifier.state.resources.copyWith(food: 50000.0),
        progression: notifier.state.progression.copyWith(castleLevel: 10),
      );

      final conquerSuccess = notifier.conquerTile(dist4Shrine.coord);
      expect(conquerSuccess, isTrue);

      final updatedTile = notifier.state.tiles[dist4Shrine.coord];
      expect(updatedTile!.isOwned, isTrue);
      final workerMult = EconomyCalculator.getWorkerTransferMultiplier(tiles: notifier.state.tiles);
      expect(workerMult, greaterThanOrEqualTo(2.0));
      expect(workerMult, closeTo(dist4Shrine.shrineMultiplierValue, 0.001),
          reason: 'Lojistik hızı tapınağı fethiyle taşıma katsayısı artmalıdır');
    });
  });
}
