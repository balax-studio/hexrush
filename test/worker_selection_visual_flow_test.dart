import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Worker Hut Selection Visual Flow & Range Tests', () {
    test('Worker selection detects in-range owned tiles and producer contributors', () {
      const workerCoord = HexAxial(2, 2);

      final tiles = <HexAxial, HexTileModel>{
        // İşçi kulübesi
        workerCoord: const HexTileModel(
          coord: workerCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker, level: 1),
        ),
        // Menzilde (mesafe 1) fethedilmiş mısır tarlası (üretim binası)
        const HexAxial(2, 3): const HexTileModel(
          coord: HexAxial(2, 3),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        // Menzilde (mesafe 3) fethedilmiş taş ocağı (üretim binası)
        const HexAxial(2, 5): const HexTileModel(
          coord: HexAxial(2, 5),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.quarry, level: 1),
        ),
        // Menzilde (mesafe 2) fethedilmiş boş çayır (bina yok ama fethedilmiş alan)
        const HexAxial(3, 2): const HexTileModel(
          coord: HexAxial(3, 2),
          biome: TileBiome.meadow,
          state: TileState.owned,
        ),
        // Menzilde (mesafe 2) ama henüz fethedilmemiş (unowned) arazi
        const HexAxial(1, 2): const HexTileModel(
          coord: HexAxial(1, 2),
          biome: TileBiome.meadow,
          state: TileState.discovered,
        ),
        // Menzilde (mesafe 2) ama sisli (fog) arazi
        const HexAxial(2, 0): const HexTileModel(
          coord: HexAxial(2, 0),
          biome: TileBiome.meadow,
          state: TileState.fog,
        ),
        // Menzil dışında (mesafe 5) fethedilmiş oduncu
        const HexAxial(7, 2): const HexTileModel(
          coord: HexAxial(7, 2),
          biome: TileBiome.forest,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.lumberjack, level: 1),
        ),
      };

      final state = GameState(
        tiles: tiles,
        selectedCoord: workerCoord,
      );

      final selectedTile = state.selectedCoord != null ? state.tiles[state.selectedCoord!] : null;
      expect(selectedTile, isNotNull);
      expect(selectedTile!.building?.type, equals(BuildingType.worker));

      final Set<HexAxial> workerRangeCoords = {};
      final List<HexAxial> producerCoords = [];

      for (final entry in state.tiles.entries) {
        final coord = entry.key;
        final tile = entry.value;
        if (!tile.isOwned || tile.isFog) continue;

        if (coord.distanceTo(workerCoord) <= 4) {
          workerRangeCoords.add(coord);

          if (coord != workerCoord && tile.hasBuilding) {
            final b = tile.building!;
            if (b.type != BuildingType.castle &&
                b.type != BuildingType.worker &&
                b.type != BuildingType.watchtower &&
                b.type != BuildingType.bridge &&
                b.type != BuildingType.fishermanHut &&
                b.type != BuildingType.granaryVault) {
              producerCoords.add(coord);
            }
          }
        }
      }

      // Menzildeki fethedilmiş alanlar (işçi kulübesi, mısır, taş ocağı, boş çayır)
      expect(workerRangeCoords.contains(const HexAxial(2, 3)), isTrue);
      expect(workerRangeCoords.contains(const HexAxial(2, 5)), isTrue);
      expect(workerRangeCoords.contains(const HexAxial(3, 2)), isTrue);

      // Sisli veya sahipsiz veya menzil dışı araziler menzilde olmamalı
      expect(workerRangeCoords.contains(const HexAxial(1, 2)), isFalse);
      expect(workerRangeCoords.contains(const HexAxial(2, 0)), isFalse);
      expect(workerRangeCoords.contains(const HexAxial(7, 2)), isFalse);

      // Malzeme tedarik eden üretim binaları
      expect(producerCoords, containsAll([const HexAxial(2, 3), const HexAxial(2, 5)]));
      expect(producerCoords.contains(const HexAxial(3, 2)), isFalse); // Boş çayır üretici değil
      expect(producerCoords.contains(const HexAxial(7, 2)), isFalse); // Menzil dışı
    });
  });
}
