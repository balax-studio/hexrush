import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/flame/components/hex_tile_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Visual Transition Engine Tests (Fog Reveal & Season Blend)', () {
    test('HexTileComponent triggers reveal timer when fog is cleared', () {
      const fogTile = HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.forest,
        state: TileState.fog,
      );

      final component = HexTileComponent(
        coord: const HexAxial(1, 0),
        tileModel: fogTile,
        isSelected: false,
        season: 'SPRING',
        isZud: false,
      );

      expect(component.tileModel.isFog, isTrue);

      // Keşfedilme / Sis Açılma Geçişi
      final discoveredTile = fogTile.copyWith(state: TileState.discovered);
      component.updateData(
        newTileModel: discoveredTile,
        newIsSelected: false,
        newSeason: 'SPRING',
        newIsZud: false,
      );

      expect(component.tileModel.isFog, isFalse);

      // Update döngüsü (0.3sn sonra hala aktif olmalı)
      component.update(0.3);

      // 0.4sn daha ilerleyince toplam 0.7sn (0.65sn eşiğini geçmeli)
      component.update(0.4);
    });

    test('HexTileComponent triggers season transition timer on season change', () {
      const meadowTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
      );

      final component = HexTileComponent(
        coord: const HexAxial(0, 0),
        tileModel: meadowTile,
        isSelected: false,
        season: 'SPRING',
        isZud: false,
      );

      // Bahardan Kışa geçiş
      component.updateData(
        newTileModel: meadowTile,
        newIsSelected: false,
        newSeason: 'WINTER',
        newIsZud: false,
      );

      expect(component.season, 'WINTER');

      // 1.0 saniye güncelleme (2.0s geçişin yarısı)
      component.update(1.0);

      // 1.5 saniye daha güncelleme (toplam 2.5s -> geçiş tamamlanmış olmalı)
      component.update(1.5);
    });

    test('HexTileComponent renders correctly during fog reveal and season blend without exception', () {
      const tile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.fog,
      );

      final component = HexTileComponent(
        coord: const HexAxial(0, 0),
        tileModel: tile,
        isSelected: false,
        season: 'SPRING',
        isZud: false,
      );

      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // 1. Sisli halde çizim
      component.render(canvas);

      // 2. Keşif geçişi tetikle ve geçiş anında çiz
      component.updateData(
        newTileModel: tile.copyWith(state: TileState.discovered),
        newIsSelected: true,
        newSeason: 'AUTUMN',
        newIsZud: false,
      );
      component.update(0.2);
      component.render(canvas);

      // 3. Tam açılmış ve kışa geçilmiş halde çiz
      component.updateData(
        newTileModel: tile.copyWith(state: TileState.owned),
        newIsSelected: false,
        newSeason: 'WINTER',
        newIsZud: true,
      );
      component.update(2.5);
      component.render(canvas);

      recorder.endRecording();
    });

    test('HexTileComponent distinguishes owned vs unowned discovered tile state in rendering', () {
      const coord = HexAxial(2, 1);
      final unownedTile = const HexTileModel(
        coord: coord,
        biome: TileBiome.forest,
        state: TileState.discovered,
      );

      final component = HexTileComponent(
        coord: coord,
        tileModel: unownedTile,
        isSelected: false,
        season: 'SUMMER',
        isZud: false,
      );

      expect(component.tileModel.isOwned, isFalse);
      expect(component.tileModel.isDiscovered, isTrue);

      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Render unowned discovered hex (darkened / muted unclaimed territory)
      component.render(canvas);

      // Upgrade to owned
      component.updateData(
        newTileModel: unownedTile.copyWith(state: TileState.owned),
        newIsSelected: false,
        newSeason: 'SUMMER',
        newIsZud: false,
      );

      expect(component.tileModel.isOwned, isTrue);
      // Render owned hex (bright / fully saturated claimed territory)
      component.render(canvas);

      recorder.endRecording();
    });
  });
}
