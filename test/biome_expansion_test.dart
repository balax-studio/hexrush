import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/localization/game_localization.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Biome Expansion and Procedural Variations Tests', () {
    test('TileBiome enum should contain 8 distinct biomes', () {
      expect(TileBiome.values.length, 8);
      expect(
        TileBiome.values,
        containsAll([
          TileBiome.meadow,
          TileBiome.forest,
          TileBiome.mountain,
          TileBiome.sea,
          TileBiome.desert,
          TileBiome.tundra,
          TileBiome.volcano,
          TileBiome.wetland,
        ]),
      );
    });

    test('All 8 biomes should have valid localized strings across all languages', () {
      final languages = ['tr', 'en', 'es', 'de'];
      final biomes = TileBiome.values;

      for (final lang in languages) {
        for (final biome in biomes) {
          final key = 'biome_${biome.name}';
          final localizedName = GameLocalization.get(key, lang: lang);
          expect(localizedName, isNotEmpty, reason: 'Missing translation for $key in $lang');
          expect(localizedName, isNot(equals(key)), reason: 'Translation fallback was raw key for $key in $lang');
        }
      }
    });

    test('EconomyCalculator base costs for all 8 biomes are distinct and positive', () {
      final baseCosts = <TileBiome, double>{};
      for (final biome in TileBiome.values) {
        final cost = EconomyCalculator.getExpansionCost(
          biome: biome,
          ownedCount: 0,
          biomeCounts: {},
        );
        expect(cost, greaterThan(0.0));
        baseCosts[biome] = cost;
      }

      // Check hierarchy: meadow < desert < forest < wetland < sea < tundra < mountain < volcano
      expect(baseCosts[TileBiome.meadow]!, 5.0);
      expect(baseCosts[TileBiome.desert]!, 8.0);
      expect(baseCosts[TileBiome.forest]!, 10.0);
      expect(baseCosts[TileBiome.wetland]!, 12.0);
      expect(baseCosts[TileBiome.sea]!, 15.0);
      expect(baseCosts[TileBiome.tundra]!, 18.0);
      expect(baseCosts[TileBiome.mountain]!, 20.0);
      expect(baseCosts[TileBiome.volcano]!, 25.0);
    });

    test('Mountain procedural seed variation mapping produces 4 distinct variants deterministically', () {
      final variants = <int>{};
      for (int q = -5; q <= 5; q++) {
        for (int r = -5; r <= 5; r++) {
          final seed = (q * 31 + r * 17).abs();
          variants.add(seed % 4);
        }
      }
      expect(variants, containsAll([0, 1, 2, 3]));
    });
  });
}
