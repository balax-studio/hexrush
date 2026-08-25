import 'dart:math' as math;
import '../../core/hex/hex_coordinates.dart';
import '../models/building_model.dart';
import '../models/doctrine_model.dart';
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

class NetResourceRates {
  final double food;
  final double wood;
  final double stone;
  final double iron;
  final double flour;
  final double plank;
  final double bread;
  final double furniture;
  final double fish;

  const NetResourceRates({
    this.food = 0.0,
    this.wood = 0.0,
    this.stone = 0.0,
    this.iron = 0.0,
    this.flour = 0.0,
    this.plank = 0.0,
    this.bread = 0.0,
    this.furniture = 0.0,
    this.fish = 0.0,
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
    int distance = 0,
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
  }) {
    final discount = getExpansionDiscount(
      toreTalents: toreTalents,
      titles: titles,
    );

    double base = 5.0;
    switch (biome) {
      case TileBiome.meadow:
        base = 5.0;
        break;
      case TileBiome.desert:
        base = 8.0;
        break;
      case TileBiome.forest:
        base = 10.0;
        break;
      case TileBiome.wetland:
        base = 12.0;
        break;
      case TileBiome.sea:
        base = 15.0;
        break;
      case TileBiome.tundra:
        base = 18.0;
        break;
      case TileBiome.mountain:
        base = 20.0;
        break;
      case TileBiome.volcano:
        base = 25.0;
        break;
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

    // Mesafe Sınırı (Soft-Wall): Merkezden 20 birim uzaktaki yerler satın alınamaz olsun (x10000)
    double distanceMult = 1.0;
    if (distance > 20) {
      distanceMult = 10000.0;
    }

    // Biyom Yoğunluğu Çarpanı: Aynı biyomdan daha fazla fethedildikçe hafif ölçeklenme
    final int bCount = biomeCounts[biome.name] ?? 0;
    final double biomeScaling = math.pow(1.05, bCount).toDouble();

    final double cost = base *
        math.pow(1.6, ownedCount) *
        wallMult *
        biomeScaling *
        (1.0 - discount) *
        distanceMult;
    return math.max(1.0, cost.roundToDouble());
  }

  static Map<String, double> getCastleUpgradeCost(int nextLevel) {
    final double foodCost = 50.0 * math.pow(1.5, nextLevel - 2);
    // İlk birkaç seviye (Lvl 5'e kadar) odun istemesin (Soft-lock önleme)
    final double woodCost =
        nextLevel <= 5 ? 0.0 : 25.0 * math.pow(1.5, nextLevel - 6);

    return {
      'food': foodCost,
      'wood': woodCost,
    };
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
          gainedIron += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          break;
        case BuildingType.fisherman:
          gainedFish += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.shrine:
        case BuildingType.castle:
        case BuildingType.worker:
        case BuildingType.watchtower:
        case BuildingType.bridge:
        case BuildingType.fishermanHut:
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

  /// Anlık Saniyelik Net Üretim/Tüketim Debisi (HUD Rozetleri ve Analitik için)
  static NetResourceRates calculateNetRates({
    required Iterable<HexTileModel> tiles,
    required double globalMultiplier,
    required double seasonMultiplier,
    required double shrineMultiplier,
    Map<HexAxial, HexTileModel>? tileMap,
    String season = 'SPRING',
    bool isZud = false,
  }) {
    final double totalMult = globalMultiplier * seasonMultiplier * shrineMultiplier;

    double netFood = 0.0;
    double netWood = 0.0;
    double netStone = 0.0;
    double netIron = 0.0;
    double netFlour = 0.0;
    double netPlank = 0.0;
    double netBread = 0.0;
    double netFurniture = 0.0;
    double netFish = 0.0;

    final map = tileMap ?? {for (final t in tiles) t.coord: t};

    for (final t in tiles) {
      if (!t.isOwned || !t.hasBuilding) continue;
      final b = t.building!;

      final neighborTiles = t.coord.neighbors
          .map((nc) => map[nc])
          .whereType<HexTileModel>()
          .toList();

      final double biomeSynergy = calculateAdjacencySynergy(
        targetTile: t,
        neighborTiles: neighborTiles,
        season: season,
        isZud: isZud,
      );

      final double rate = (b.baseProductionRate * math.pow(1.5, b.level - 1)) * totalMult * biomeSynergy;

      switch (b.type) {
        case BuildingType.corn:
          netFood += rate;
          break;
        case BuildingType.lumberjack:
          netWood += rate;
          break;
        case BuildingType.windmill:
          netFlour += rate;
          break;
        case BuildingType.sawmill:
          netPlank += rate;
          break;
        case BuildingType.bakery:
          netBread += rate;
          break;
        case BuildingType.furniture:
          netFurniture += rate;
          break;
        case BuildingType.mine:
          netStone += rate;
          netIron += rate * 0.3;
          break;
        case BuildingType.fisherman:
          netFish += rate;
          break;
        case BuildingType.shrine:
        case BuildingType.castle:
        case BuildingType.worker:
        case BuildingType.watchtower:
        case BuildingType.bridge:
        case BuildingType.fishermanHut:
          break;
      }
    }

    return NetResourceRates(
      food: netFood,
      wood: netWood,
      stone: netStone,
      iron: netIron,
      flour: netFlour,
      plank: netPlank,
      bread: netBread,
      furniture: netFurniture,
      fish: netFish,
    );
  }

  /// Karoların komşuluk ve biyom sinerji çarpanlarını hesaplar (Adjacency Aura)
  static double calculateAdjacencySynergy({
    required HexTileModel targetTile,
    required List<HexTileModel> neighborTiles,
    required String season,
    required bool isZud,
  }) {
    if (!targetTile.hasBuilding) return 1.0;
    final bType = targetTile.building!.type;
    double synergy = 1.0;

    for (final neighbor in neighborTiles) {
      if (neighbor.isFog) continue;

      switch (neighbor.biome) {
        case TileBiome.wetland:
        case TileBiome.sea:
          // Sazlık / Deniz: Çiftliklere ve Değirmenlere +%30 Sulama Bereketi
          if (bType == BuildingType.corn || bType == BuildingType.windmill) {
            synergy += 0.30;
          }
          // Deniz: Fırın ve Balıkçılara +%20 Lojistik Kolaylığı
          if (bType == BuildingType.bakery ||
              bType == BuildingType.fisherman ||
              bType == BuildingType.fishermanHut) {
            synergy += 0.20;
          }
          break;

        case TileBiome.volcano:
          // Volkan: Madenlere +%50 Jeotermal Isı & Dökümhane Bonusu
          if (bType == BuildingType.mine) {
            synergy += 0.50;
          }
          // Orman binalarına kuruma/kül riski (-%15)
          if (bType == BuildingType.lumberjack || bType == BuildingType.sawmill) {
            synergy -= 0.15;
          }
          break;

        case TileBiome.desert:
          // Çöl: Değirmen & Mobilyacıya +%40 İpek Yolu Ticaret Bonusu
          if (bType == BuildingType.windmill || bType == BuildingType.furniture) {
            synergy += 0.40;
          }
          // Çiftliklere kuraklık cezası (-%20)
          if (bType == BuildingType.corn) {
            synergy -= 0.20;
          }
          break;

        case TileBiome.mountain:
          // Dağ: Madenlere +%35 Zengin Damar Bonusu
          if (bType == BuildingType.mine) {
            synergy += 0.35;
          }
          // Gözetleme Kulesine +%50 Rüzgar Siperi & Görüş
          if (bType == BuildingType.watchtower) {
            synergy += 0.50;
          }
          break;

        case TileBiome.forest:
          // Orman: Marangoz & Mobilyacıya +%25 Kereste Yakınlığı
          if (bType == BuildingType.sawmill || bType == BuildingType.furniture) {
            synergy += 0.25;
          }
          break;

        case TileBiome.tundra:
          // Tundra: Kışın soğuk cezası (-%25), ancak Madenlere +%20 Permafrost Taş Bonusu
          if (season.toUpperCase() == 'WINTER' || isZud) {
            if (bType == BuildingType.corn) synergy -= 0.25;
          }
          if (bType == BuildingType.mine) synergy += 0.20;
          break;

        case TileBiome.meadow:
          // Çayır: Çiftliklere +%10 Verimli Toprak
          if (bType == BuildingType.corn) {
            synergy += 0.10;
          }
          break;
      }
    }

    return math.max(0.20, synergy);
  }

  /// Aktif komşuluk sinerjilerinin açıklamalarını ve oranlarını döndürür (UI Rozetleri için)
  static List<String> getActiveSynergyLabels({
    required HexTileModel targetTile,
    required List<HexTileModel> neighborTiles,
    required String season,
    required bool isZud,
  }) {
    if (!targetTile.hasBuilding) return const [];
    final bType = targetTile.building!.type;
    final List<String> labels = [];

    for (final neighbor in neighborTiles) {
      if (neighbor.isFog) continue;

      switch (neighbor.biome) {
        case TileBiome.wetland:
        case TileBiome.sea:
          if (bType == BuildingType.corn || bType == BuildingType.windmill) {
            labels.add('+30% Sulama Bereketi (Su/Sazlık)');
          }
          if (bType == BuildingType.bakery ||
              bType == BuildingType.fisherman ||
              bType == BuildingType.fishermanHut) {
            labels.add('+20% Lojistik Kolaylığı (Deniz)');
          }
          break;

        case TileBiome.volcano:
          if (bType == BuildingType.mine) {
            labels.add('+50% Jeotermal Dökümhane (Volkan)');
          }
          if (bType == BuildingType.lumberjack || bType == BuildingType.sawmill) {
            labels.add('-15% Kül Kuruması (Volkan)');
          }
          break;

        case TileBiome.desert:
          if (bType == BuildingType.windmill || bType == BuildingType.furniture) {
            labels.add('+40% İpek Yolu Ticareti (Çöl)');
          }
          if (bType == BuildingType.corn) {
            labels.add('-20% Kuraklık (Çöl)');
          }
          break;

        case TileBiome.mountain:
          if (bType == BuildingType.mine) {
            labels.add('+35% Zengin Damar (Dağ)');
          }
          if (bType == BuildingType.watchtower) {
            labels.add('+50% Rüzgar Siperi (Dağ)');
          }
          break;

        case TileBiome.forest:
          if (bType == BuildingType.sawmill || bType == BuildingType.furniture) {
            labels.add('+25% Kereste Yakınlığı (Orman)');
          }
          break;

        case TileBiome.tundra:
          if (season.toUpperCase() == 'WINTER' || isZud) {
            if (bType == BuildingType.corn) labels.add('-25% Ayaz Şoku (Tundra)');
          }
          if (bType == BuildingType.mine) labels.add('+20% Permafrost Taş (Tundra)');
          break;

        case TileBiome.meadow:
          if (bType == BuildingType.corn) {
            labels.add('+10% Verimli Çayır (Çayır)');
          }
          break;
      }
    }

    return labels;
  }

  /// Aktif doktrinlerin bina türüne göre getirdiği ek üretim çarpanı
  static double getDoctrineProductionMultiplier({
    required BuildingType buildingType,
    required List<DoctrineCardModel> activeDoctrines,
  }) {
    double mult = 1.0;
    for (final doc in activeDoctrines) {
      if (doc.effectType == DoctrineEffectType.cropBonus &&
          (buildingType == BuildingType.corn || buildingType == BuildingType.windmill)) {
        mult += doc.effectValue;
      }
      if (doc.effectType == DoctrineEffectType.desertTradeBonus &&
          (buildingType == BuildingType.windmill ||
           buildingType == BuildingType.furniture ||
           buildingType == BuildingType.bakery)) {
        mult += doc.effectValue;
      }
    }
    return mult;
  }

  /// Aktif doktrinlere göre karo fetih maliyeti çarpanı
  static double getConquestCostMultiplier(List<DoctrineCardModel> activeDoctrines) {
    double discount = 0.0;
    for (final doc in activeDoctrines) {
      if (doc.effectType == DoctrineEffectType.conquestDiscount) {
        discount += doc.effectValue;
      }
    }
    return math.max(0.2, 1.0 - discount);
  }

  /// Aktif doktrinlere göre kış ısıtma odun maliyeti
  static double getWinterWarmWoodCost(List<DoctrineCardModel> activeDoctrines) {
    for (final doc in activeDoctrines) {
      if (doc.effectType == DoctrineEffectType.winterWarmDiscount) {
        return math.max(1.0, 5.0 - doc.effectValue);
      }
    }
    return 5.0;
  }
}
