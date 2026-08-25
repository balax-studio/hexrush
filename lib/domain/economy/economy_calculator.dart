import 'dart:math' as math;
import '../models/building_model.dart';
import '../models/hex_tile_model.dart';

class MarketTradeResult {
  final bool success;
  final Map<String, double> consumed;
  final Map<String, double> gained;

  const MarketTradeResult({
    required this.success,
    this.consumed = const {},
    this.gained = const {},
  });
}

class OfflineGainsResult {
  final int seconds;
  final double food;
  final double wood;
  final double flour;
  final double plank;
  final double bread;
  final double furniture;
  final double stone;
  final double iron;
  final double fish;

  const OfflineGainsResult({
    required this.seconds,
    this.food = 0.0,
    this.wood = 0.0,
    this.flour = 0.0,
    this.plank = 0.0,
    this.bread = 0.0,
    this.furniture = 0.0,
    this.stone = 0.0,
    this.iron = 0.0,
    this.fish = 0.0,
  });

  bool get hasGains =>
      food > 0 ||
      wood > 0 ||
      flour > 0 ||
      plank > 0 ||
      bread > 0 ||
      furniture > 0 ||
      stone > 0 ||
      iron > 0 ||
      fish > 0;
}

/// Krallık Ekonomisi, Töre Ağacı & Yetenek Hesaplayıcı (Pure Dart Engine)
class EconomyCalculator {
  static double getGlobalMultiplier({
    required int castleLevel,
    required int crowns,
    Map<String, dynamic> talents = const {},
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
  }) {
    final double castleMult = 1.0 + (castleLevel - 1) * 0.25;
    final double prestigeBonus = crowns * 0.05;

    // Yetenek Ağacı Çarpanları
    final double talentBoost = (talents['boostAll'] as num? ?? 0) * 0.05;

    // Töre Ağacı Çarpanları
    double toreBoost = 0.0;
    if (toreTalents.containsKey('gokTengri')) {
      final gokTengri = toreTalents['gokTengri'] as Map<String, dynamic>;
      final rain = (gokTengri['rainBlessing'] as num? ?? 0);
      toreBoost += rain * 0.05;
    }
    if (toreTalents.containsKey('tonyukuk')) {
      final tonyukuk = toreTalents['tonyukuk'] as Map<String, dynamic>;
      final silk = (tonyukuk['silkNetwork'] as num? ?? 0);
      toreBoost += silk * 0.04;
    }

    // Unvan Bonusları
    double titleBoost = 0.0;
    if (titles['khagan'] == true) {
      titleBoost += 0.15;
    }

    final double prestigeMult =
        1.0 + prestigeBonus + talentBoost + toreBoost + titleBoost;
    return castleMult * prestigeMult;
  }

  static double getWorkerTransferMultiplier({
    Map<String, dynamic> talents = const {},
    Map<String, dynamic> toreTalents = const {},
  }) {
    final int speedLvl = (talents['workerSpeed'] as num? ?? 0).toInt();
    int roadLvl = 0;
    if (toreTalents.containsKey('tonyukuk')) {
      final tonyukuk = toreTalents['tonyukuk'] as Map<String, dynamic>;
      roadLvl = (tonyukuk['pavedRoads'] as num? ?? 0).toInt();
    }
    return 1.0 + speedLvl * 0.10 + roadLvl * 0.08;
  }

  static double getExpansionDiscount({
    Map<String, dynamic> talents = const {},
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
  }) {
    final int conquestLvl = (talents['conquestMaster'] as num? ?? 0).toInt();
    double discount = conquestLvl * 0.03;
    if (toreTalents.containsKey('kulTigin')) {
      final kulTigin = toreTalents['kulTigin'] as Map<String, dynamic>;
      discount += (kulTigin['braveHeart'] as num? ?? 0) * 0.05;
    }
    if (titles['conqueror'] == true) {
      discount += 0.10;
    }
    return math.min(0.60, discount);
  }

  static double getExpansionCost({
    required TileBiome biome,
    required int ownedCount,
    required Map<String, int> biomeCounts,
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
  }) {
    final discount = getExpansionDiscount(
      toreTalents: toreTalents,
      titles: titles,
    );

    double base = 5.0;
    if (biome == TileBiome.forest) {
      base = 10.0;
    } else if (biome == TileBiome.sea) {
      base = 15.0;
    } else if (biome == TileBiome.mountain) {
      base = 20.0;
    }

    // C(n) = C_base * 1.6^n * W(n)
    double wallMult = 1.0;
    if (ownedCount >= 50) {
      wallMult = 50.0;
    } else if (ownedCount >= 20) {
      wallMult = 10.0;
    } else if (ownedCount >= 10) {
      wallMult = 5.0;
    }

    final double cost = base * math.pow(1.6, ownedCount) * wallMult * (1.0 - discount);
    return math.max(1.0, cost.roundToDouble());
  }

  static double calculateBuildingProduction({
    required BuildingType type,
    required int level,
    required double baseRate,
    double globalMultiplier = 1.0,
    double seasonMultiplier = 1.0,
    double synergyMultiplier = 1.0,
    double workerMultiplier = 1.0,
    double shrineMultiplier = 1.0,
  }) {
    // Eşik Çarpanı (k)
    int k = 0;
    if (level >= 200) {
      k = 5;
    } else if (level >= 100) {
      k = 4;
    } else if (level >= 50) {
      k = 3;
    } else if (level >= 25) {
      k = 2;
    } else if (level >= 10) {
      k = 1;
    }

    // P_net = (P_base * Level * 2^k) * (1 + sum S_boost) * modifiers
    final double milestoneBoost = math.pow(2.0, k).toDouble();

    return (baseRate * level * milestoneBoost) *
           globalMultiplier *
           seasonMultiplier *
           synergyMultiplier *
           workerMultiplier *
           shrineMultiplier;
  }

  static double getTamgaMultiplier(int tamga) {
    if (tamga <= 0) return 1.0;

    if (tamga <= 100) {
      // 0-100 Tamga: 1.0 + (Tamga * 0.1)
      return 1.0 + (tamga * 0.1);
    } else {
      // 100+ Tamga: 11.0 + log10(Tamga - 99)
      return 11.0 + (math.log(tamga - 99.0) / math.ln10);
    }
  }

  static double getSeasonProductionMultiplier({
    required String season,
    required bool isZud,
    required bool isTileWarmed,
    Map<String, dynamic> titles = const {},
  }) {
    if (isTileWarmed) {
      return 1.50; // Isıtılmış karo +%50 hız
    }

    switch (season.toUpperCase()) {
      case 'SPRING':
        return 1.25; // Bahar bereketi
      case 'SUMMER':
        return 1.10; // Yaz güneşi
      case 'AUTUMN':
        return 1.00; // Normal hasat
      case 'WINTER':
        double lossPenalty = isZud ? 0.60 : 0.80;
        if (titles['zudMaster'] == true) {
          lossPenalty = math.min(1.0, lossPenalty + 0.20);
        }
        return lossPenalty;
      default:
        return 1.0;
    }
  }

  static MarketTradeResult calculateMarketTrade({
    required String recipeKey,
    required Map<String, double> resources,
    Map<String, dynamic> titles = const {},
  }) {
    final double merchantBonus = titles['merchant'] == true ? 1.20 : 1.0;

    if (recipeKey == 'flour_to_stone') {
      if ((resources['flour'] ?? 0.0) >= 15.0) {
        return MarketTradeResult(
          success: true,
          consumed: {'flour': 15.0},
          gained: {'stone': (8.0 * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'bread_to_iron') {
      if ((resources['bread'] ?? 0.0) >= 10.0) {
        return MarketTradeResult(
          success: true,
          consumed: {'bread': 10.0},
          gained: {'iron': (5.0 * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'furniture_to_stone') {
      if ((resources['furniture'] ?? 0.0) >= 10.0) {
        return MarketTradeResult(
          success: true,
          consumed: {'furniture': 10.0},
          gained: {'stone': (15.0 * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'iron_stone_to_crown') {
      if ((resources['iron'] ?? 0.0) >= 25.0 &&
          (resources['stone'] ?? 0.0) >= 25.0) {
        return const MarketTradeResult(
          success: true,
          consumed: {'iron': 25.0, 'stone': 25.0},
          gained: {'crowns': 1.0},
        );
      }
    }

    return const MarketTradeResult(success: false);
  }

  static OfflineGainsResult calculateOfflineGains({
    required List<HexTileModel> tiles,
    required double elapsedSeconds,
    required double globalMultiplier,
  }) {
    const double maxOfflineSeconds = 8 * 3600.0;
    final double cappedSeconds = math.min(maxOfflineSeconds, math.max(0.0, elapsedSeconds));
    if (cappedSeconds < 15.0) {
      return OfflineGainsResult(seconds: cappedSeconds.toInt());
    }

    final bool hasWorkers = tiles.any((t) =>
        t.building?.type == BuildingType.worker ||
        t.building?.type == BuildingType.fishermanHut);

    double gainedFood = 0.0;
    double gainedWood = 0.0;
    double gainedFlour = 0.0;
    double gainedPlank = 0.0;
    double gainedBread = 0.0;
    double gainedFurniture = 0.0;
    double gainedStone = 0.0;
    double gainedIron = 0.0;
    double gainedFish = 0.0;

    for (final t in tiles) {
      final b = t.building;
      if (b == null) continue;

      final double rate = (b.baseProductionRate * math.pow(1.5, b.level - 1)) *
          globalMultiplier;
      final double maxCap = rate * 30.0;

      switch (b.type) {
        case BuildingType.corn:
          gainedFood += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.lumberjack:
          gainedWood += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.windmill:
          gainedFlour += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.sawmill:
          gainedPlank += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.bakery:
          gainedBread += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.furniture:
          gainedFurniture += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.mine:
          gainedStone += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.fisherman:
          gainedFish += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        default:
          break;
      }
    }

    return OfflineGainsResult(
      seconds: cappedSeconds.toInt(),
      food: gainedFood,
      wood: gainedWood,
      flour: gainedFlour,
      plank: gainedPlank,
      bread: gainedBread,
      furniture: gainedFurniture,
      stone: gainedStone,
      iron: gainedIron,
      fish: gainedFish,
    );
  }
}
