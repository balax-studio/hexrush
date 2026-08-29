import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Initial Shrine Placement Tests', () {
    test('Başlangıçta (0, 1) görünür çayır karosunda garantili Kutlu Tapınak yer alır', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;

      // 1. (0, 1) koordinatındaki karo kontrolü
      const initialShrineCoord = HexAxial(0, 1);
      final initialTile = state.tiles[initialShrineCoord];

      expect(initialTile, isNotNull);
      expect(initialTile!.state, equals(TileState.discovered),
          reason: 'Başlangıçta tapınak karosu sis altında olmamalı, görünür (discovered) olmalı');
      expect(initialTile.hasShrine, isTrue,
          reason: 'Başlangıçta (0, 1) karosunda kutlu tapınak bulunmalıdır');
      expect(initialTile.shrine, equals(ShrineType.foodBoost),
          reason: 'Erken safhada oyuncunun gelişimini hızlandırmak için ilk tapınak Gıda Bereketi olmalıdır');
      expect(initialTile.biome, equals(TileBiome.meadow),
          reason: 'İlk tapınak Seviye 1 Kağan Otağı ile hemen fethedilebilen Çayır biyomunda olmalıdır');

      // 2. Haritada toplam 11 adet Kutlu Tapınak olduğunu doğrula
      final totalShrines = state.tiles.values.where((t) => t.hasShrine).length;
      expect(totalShrines, equals(11),
          reason: 'Harita genelinde toplam 11 adet kutlu tapınak dengesi korunmalıdır');
    });

    test('Başlangıçtaki tapınak fethedildiğinde bereket çarpanı devreye girer', () {
      final notifier = GameStateNotifier();
      const initialShrineCoord = HexAxial(0, 1);

      final initialMultiplier = notifier.state.shrineMultiplier;
      expect(initialMultiplier, equals(1.0));

      // Yeterli gıda ile karoyu fethet
      final success = notifier.conquerTile(initialShrineCoord);
      expect(success, isTrue);

      final updatedTile = notifier.state.tiles[initialShrineCoord];
      expect(updatedTile!.isOwned, isTrue);
      expect(notifier.state.shrineMultiplier, greaterThan(1.0));
      expect(notifier.state.shrineMultiplier, closeTo(1.30, 0.001),
          reason: 'Gıda bereketi tapınağı fethiyle çarpan +%30 (1.30) olmalıdır');
    });
  });
}
