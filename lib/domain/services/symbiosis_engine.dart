import '../models/hex_tile_model.dart';
import '../../core/hex/hex_coordinates.dart';

enum SymbiosisType {
  none,
  wildGlade, // 3+ Orman + 1 Sulak -> Vahşi Koruluk (Nadir Polen & Şifalı Bitki)
  canyonOasis, // Çöl + Dağ -> Kanyon Vahası (Tuz, Baharat & Altın)
  crystalSpring, // Dağ + Deniz/Göl -> Kristal Pınar (Saf Su & Kristal)
  volcanicGeothermal, // Volkan + Sulak/Tundra -> Jeotermal Gayzer (Isı & Obsidyen)
}

class SymbiosisEngine {
  /// Evaluates the 6 neighboring biomes of [coord] across [tilesMap]
  /// and returns any cascading hybrid symbiosis mutation.
  static SymbiosisType evaluateSymbiosis(HexAxial coord, Map<HexAxial, HexTileModel> tilesMap) {
    final currentTile = tilesMap[coord];
    if (currentTile == null || !currentTile.isOwned) return SymbiosisType.none;

    final neighbors = coord.neighbors;
    int forestCount = 0;
    int wetlandCount = 0;
    int desertCount = 0;
    int mountainCount = 0;
    int seaCount = 0;
    int volcanoCount = 0;
    int tundraCount = 0;

    for (final n in neighbors) {
      final neighborTile = tilesMap[n];
      if (neighborTile == null || !neighborTile.isOwned) continue;

      switch (neighborTile.biome) {
        case TileBiome.forest:
          forestCount++;
          break;
        case TileBiome.wetland:
          wetlandCount++;
          break;
        case TileBiome.desert:
          desertCount++;
          break;
        case TileBiome.mountain:
          mountainCount++;
          break;
        case TileBiome.sea:
          seaCount++;
          break;
        case TileBiome.volcano:
          volcanoCount++;
          break;
        case TileBiome.tundra:
          tundraCount++;
          break;
        default:
          break;
      }
    }

    // 1. Vahşi Koruluk (Wild Glade): Çayır üzerinde en az 2 Orman ve 1 Sulak alan
    if (currentTile.biome == TileBiome.meadow && forestCount >= 2 && wetlandCount >= 1) {
      return SymbiosisType.wildGlade;
    }

    // 2. Kanyon Vahası (Canyon Oasis): Çöl üzerinde en az 2 Dağ veya Dağ üzerinde en az 2 Çöl
    if ((currentTile.biome == TileBiome.desert && mountainCount >= 2) ||
        (currentTile.biome == TileBiome.mountain && desertCount >= 2)) {
      return SymbiosisType.canyonOasis;
    }

    // 3. Kristal Pınar (Crystal Spring): Sulak/Deniz üzerinde en az 2 Dağ
    if ((currentTile.biome == TileBiome.sea || currentTile.biome == TileBiome.wetland) && mountainCount >= 2) {
      return SymbiosisType.crystalSpring;
    }

    // 4. Jeotermal Gayzer (Volcanic Geothermal): Volkan üzerinde en az 1 Sulak/Tundra
    if (currentTile.biome == TileBiome.volcano && (wetlandCount >= 1 || tundraCount >= 1)) {
      return SymbiosisType.volcanicGeothermal;
    }

    return SymbiosisType.none;
  }

  /// Returns user-friendly name for symbiosis form
  static String getSymbiosisTitle(SymbiosisType type) {
    switch (type) {
      case SymbiosisType.wildGlade:
        return 'Vahşi Koruluk';
      case SymbiosisType.canyonOasis:
        return 'Kanyon Vahası';
      case SymbiosisType.crystalSpring:
        return 'Kristal Pınar';
      case SymbiosisType.volcanicGeothermal:
        return 'Jeotermal Gayzer';
      case SymbiosisType.none:
        return '';
    }
  }

  static String getSymbiosisName(SymbiosisType type) => getSymbiosisTitle(type);

  /// Returns extra yield multiplier (+50% for mutant biomes)
  static double getSymbiosisMultiplier(SymbiosisType type) {
    if (type == SymbiosisType.none) return 1.0;
    return 1.5;
  }
}
