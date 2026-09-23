import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Worker Hut & Granary Selection Visual Flow & Range Tests', () {
    test('Worker selection only connects to non-food producers (ignores food)', () {
      const workerCoord = HexAxial(2, 2);

      final tiles = <HexAxial, HexTileModel>{
        // İşçi kulübesi
        workerCoord: const HexTileModel(
          coord: workerCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker, level: 1),
        ),
        // Menzilde (mesafe 1) fethedilmiş mısır tarlası (Gıda üreticisi -> İşçi buna bağlanmamalı!)
        const HexAxial(2, 3): const HexTileModel(
          coord: HexAxial(2, 3),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        // Menzilde (mesafe 3) fethedilmiş taş ocağı (Hammadde üreticisi -> İşçi buna bağlanmalı)
        const HexAxial(2, 5): const HexTileModel(
          coord: HexAxial(2, 5),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.quarry, level: 1),
        ),
        // Menzilde (mesafe 2) fethedilmiş oduncu (Hammadde üreticisi -> İşçi buna bağlanmalı)
        const HexAxial(3, 2): const HexTileModel(
          coord: HexAxial(3, 2),
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

      final List<HexAxial> workerContributors = [];

      for (final entry in state.tiles.entries) {
        final coord = entry.key;
        final tile = entry.value;
        if (!tile.isOwned || tile.isFog) continue;

        if (coord.distanceTo(workerCoord) <= 4) {
          if (coord != workerCoord && tile.hasBuilding) {
            final b = tile.building!;
            if (!b.type.isFoodProducer &&
                b.type != BuildingType.castle &&
                b.type != BuildingType.worker &&
                b.type != BuildingType.watchtower &&
                b.type != BuildingType.bridge &&
                b.type != BuildingType.fishermanHut &&
                b.type != BuildingType.granaryVault) {
              workerContributors.add(coord);
            }
          }
        }
      }

      // Taş ocağı ve Oduncu bağlanmalı
      expect(workerContributors, containsAll([const HexAxial(2, 5), const HexAxial(3, 2)]));
      // Mısır tarlası gıda ürettiği için işçi kulübesine ASLA bağlanmamalı
      expect(workerContributors.contains(const HexAxial(2, 3)), isFalse);
    });

    test('Granary selection only connects to food producers', () {
      const granaryCoord = HexAxial(0, 0);

      final tiles = <HexAxial, HexTileModel>{
        // Gıda ambarı
        granaryCoord: const HexTileModel(
          coord: granaryCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.granaryVault, level: 1),
        ),
        // Menzilde (mesafe 1) fethedilmiş mısır tarlası (Gıda üreticisi -> Ambara bağlanmalı)
        const HexAxial(0, 1): const HexTileModel(
          coord: HexAxial(0, 1),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        // Menzilde (mesafe 2) fethedilmiş fırın (Gıda üreticisi -> Ambara bağlanmalı)
        const HexAxial(0, 2): const HexTileModel(
          coord: HexAxial(0, 2),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.bakery, level: 1),
        ),
        // Menzilde (mesafe 1) fethedilmiş taş ocağı (Hammadde üreticisi -> Ambara bağlanmamalı)
        const HexAxial(1, 0): const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.quarry, level: 1),
        ),
      };

      final state = GameState(
        tiles: tiles,
        selectedCoord: granaryCoord,
      );

      final selectedTile = state.selectedCoord != null ? state.tiles[state.selectedCoord!] : null;
      expect(selectedTile, isNotNull);
      expect(selectedTile!.building?.type, equals(BuildingType.granaryVault));

      final List<HexAxial> granaryContributors = [];

      for (final entry in state.tiles.entries) {
        final coord = entry.key;
        final tile = entry.value;
        if (!tile.isOwned || tile.isFog) continue;

        if (coord.distanceTo(granaryCoord) <= 4) {
          if (coord != granaryCoord && tile.hasBuilding) {
            final b = tile.building!;
            if (b.type.isFoodProducer) {
              granaryContributors.add(coord);
            }
          }
        }
      }

      // Mısır tarlası ve fırın ambara bağlanmalı
      expect(granaryContributors, containsAll([const HexAxial(0, 1), const HexAxial(0, 2)]));
      // Taş ocağı ambara ASLA bağlanmamalı
      expect(granaryContributors.contains(const HexAxial(1, 0)), isFalse);
    });
  });
}
