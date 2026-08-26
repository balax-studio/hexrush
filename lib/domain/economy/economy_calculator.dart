import 'dart:math' as math;
import '../../core/hex/hex_coordinates.dart';
import '../models/ancestral_kurgan_model.dart';
import '../models/building_model.dart';
import '../models/caravan_route_model.dart';
import '../models/celestial_omen_model.dart';
import '../models/doctrine_model.dart';
import '../models/game_state_model.dart';
import '../models/hex_tile_model.dart';
import '../services/symbiosis_engine.dart';

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
      case TileBiome.celestialCrater:
      case TileBiome.kurganValley:
      case TileBiome.crystalChasm:
        base = 50.0;
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

  static double getBiomeMasteryMultiplier({
    required TileBiome biome,
    Map<String, int> cumulativeBiomeCounts = const {},
  }) {
    final int count = cumulativeBiomeCounts[biome.name] ?? 0;
    if (count >= 10) return 1.10; // 10+ karo: +%10
    if (count >= 5) return 1.05; // 5+ karo: +%5
    return 1.0;
  }

  /// Deterministik Mevsimsel Üretim Çarpanı (Seasonal Production Boost)
  /// Bahar: Gıda zinciri +%20, Yaz: Odun zinciri +%15, Sonbahar: Maden +%15
  static double getSeasonalProductionBoost({
    required String season,
    required BuildingType buildingType,
  }) {
    switch (season.toUpperCase()) {
      case 'SPRING':
        if (buildingType == BuildingType.corn ||
            buildingType == BuildingType.barley ||
            buildingType == BuildingType.pasture ||
            buildingType == BuildingType.windmill ||
            buildingType == BuildingType.bakery ||
            buildingType == BuildingType.fisherman) {
          return 1.20;
        }
        return 1.0;
      case 'SUMMER':
        if (buildingType == BuildingType.orchard) return 1.50;
        if (buildingType == BuildingType.lumberjack ||
            buildingType == BuildingType.sawmill ||
            buildingType == BuildingType.furniture ||
            buildingType == BuildingType.resinCamp) {
          return 1.15;
        }
        return 1.0;
      case 'AUTUMN':
        if (buildingType == BuildingType.orchard) return 1.30;
        if (buildingType == BuildingType.pasture) return 1.25;
        if (buildingType == BuildingType.mine || buildingType == BuildingType.quarry) {
          return 1.15;
        }
        return 1.0;
      case 'WINTER':
        if (buildingType == BuildingType.barley) return 1.15; // Soğuğa dayanıklı
        if (buildingType == BuildingType.orchard) return 0.65; // Kış uykusu
        return 1.0;
      default:
        return 1.0;
    }
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
    double biomeMasteryMultiplier = 1.0,
    double seasonalBoostMultiplier = 1.0,
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
           shrineMultiplier *
           biomeMasteryMultiplier *
           seasonalBoostMultiplier;
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

  static List<Map<String, dynamic>> getMarketRecipes({
    required String season,
    bool isZud = false,
    bool isMerchant = false,
    required ResourcesModel resources,
  }) {
    final double merchantBonus = isMerchant ? 1.20 : 1.0;

    // 1. Un -> Taş (İlkbahar İnşaat Talebi)
    double flourToStoneGain = 8.0;
    String flourSeasonalTag = '';
    if (season == 'SPRING') {
      flourToStoneGain = 10.0; // +25%
      flourSeasonalTag = 'İLKBAHAR: +%25 TAŞ TALEBİ';
    } else if (season == 'WINTER' || isZud) {
      flourToStoneGain = 10.0;
      flourSeasonalTag = isZud ? 'ZUD: +%25 ERZAK TALEBİ' : 'KIŞ: +%25 ERZAK DEĞERİ';
    }
    final double finalFlourStone = (flourToStoneGain * merchantBonus).roundToDouble();

    // 2. Ekmek -> Demir (Kış Kıtlığı & Yaz Seferi)
    double breadToIronGain = 5.0;
    String breadSeasonalTag = '';
    if (isZud) {
      breadToIronGain = 10.0; // +100%
      breadSeasonalTag = 'ZUD BORANI: +%100 DEMİR KAZANCI!';
    } else if (season == 'WINTER') {
      breadToIronGain = 8.0; // +60%
      breadSeasonalTag = 'KARA KIŞ: +%60 DEMİR KAZANCI';
    } else if (season == 'SUMMER') {
      breadToIronGain = 6.0; // +20%
      breadSeasonalTag = 'YAZ SEFERİ: +%20 DEMİR KAZANCI';
    }
    final double finalBreadIron = (breadToIronGain * merchantBonus).roundToDouble();

    // 3. Mobilya -> Taş (Sonbahar Barınak / Otağ Yalıtımı)
    double furnitureToStoneGain = 15.0;
    String furnitureSeasonalTag = '';
    if (season == 'AUTUMN') {
      furnitureToStoneGain = 21.0; // +40%
      furnitureSeasonalTag = 'SONBAHAR: +%40 YURT YALITIM TALEBİ';
    }
    final double finalFurnitureStone = (furnitureToStoneGain * merchantBonus).roundToDouble();

    // 4. Demir + Taş -> Şan / Kutlu Tamga (Sonbahar Kurultay İndirimi)
    final double crownCost = (season == 'AUTUMN') ? 20.0 : 25.0;
    final String crownSeasonalTag = (season == 'AUTUMN') ? 'KURULTAY SEZONU: %20 İNDİRİM' : '';

    return [
      {
        'key': 'flour_to_stone',
        'fromIcon': 'flour',
        'fromAmount': '15 Un',
        'toIcon': 'stone',
        'toAmount': '${finalFlourStone.toInt()} Taş',
        'seasonTag': flourSeasonalTag,
        'desc': isMerchant
            ? 'Tüccar Unvanı (+%20) ve mevsimsel pazar kuru aktif.'
            : 'Değirmende öğütülen un ile taş takası.',
        'canAfford': resources.flour >= 15.0,
        'costFlour': 15.0,
        'gainStone': finalFlourStone,
      },
      {
        'key': 'bread_to_iron',
        'fromIcon': 'bread',
        'fromAmount': '10 Ekmek',
        'toIcon': 'iron',
        'toAmount': '${finalBreadIron.toInt()} Demir',
        'seasonTag': breadSeasonalTag,
        'desc': isMerchant
            ? 'Tüccar Unvanı (+%20) ve mevsimsel pazar kuru aktif.'
            : 'Taze pişmiş ekmek karşılığında demir madeni.',
        'canAfford': resources.bread >= 10.0,
        'costBread': 10.0,
        'gainIron': finalBreadIron,
      },
      {
        'key': 'furniture_to_stone',
        'fromIcon': 'furniture',
        'fromAmount': '10 Mobilya',
        'toIcon': 'stone',
        'toAmount': '${finalFurnitureStone.toInt()} Taş',
        'seasonTag': furnitureSeasonalTag,
        'desc': isMerchant
            ? 'Tüccar Unvanı (+%20) ve mevsimsel pazar kuru aktif.'
            : 'İşlenmiş otağ mobilyası karşılığında zengin taş kütleleri.',
        'canAfford': resources.furniture >= 10.0,
        'costFurniture': 10.0,
        'gainStone': finalFurnitureStone,
      },
      {
        'key': 'iron_stone_to_crown',
        'fromIcon': 'iron',
        'fromAmount': '${crownCost.toInt()} Demir + ${crownCost.toInt()} Taş',
        'toIcon': 'crown',
        'toAmount': '1 Şan',
        'seasonTag': crownSeasonalTag,
        'desc': 'Değerli madenleri birleştirerek hanlık şanı ve kutlu tamga döv.',
        'canAfford': resources.iron >= crownCost && resources.stone >= crownCost,
        'costIron': crownCost,
        'costStone': crownCost,
        'gainCrowns': 1.0,
      },
    ];
  }

  static MarketTradeResult calculateMarketTrade({
    required String recipeKey,
    required Map<String, double> resources,
    Map<String, dynamic> titles = const {},
    String season = 'SPRING',
    bool isZud = false,
  }) {
    final bool isMerchant = titles['merchant'] == true;
    final double merchantBonus = isMerchant ? 1.20 : 1.0;

    if (recipeKey == 'flour_to_stone') {
      if ((resources['flour'] ?? 0.0) >= 15.0) {
        double gain = 8.0;
        if (season == 'SPRING' || season == 'WINTER' || isZud) {
          gain = 10.0;
        }
        return MarketTradeResult(
          success: true,
          consumed: {'flour': 15.0},
          gained: {'stone': (gain * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'bread_to_iron') {
      if ((resources['bread'] ?? 0.0) >= 10.0) {
        double gain = 5.0;
        if (isZud) {
          gain = 10.0;
        } else if (season == 'WINTER') {
          gain = 8.0;
        } else if (season == 'SUMMER') {
          gain = 6.0;
        }
        return MarketTradeResult(
          success: true,
          consumed: {'bread': 10.0},
          gained: {'iron': (gain * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'furniture_to_stone') {
      if ((resources['furniture'] ?? 0.0) >= 10.0) {
        double gain = 15.0;
        if (season == 'AUTUMN') {
          gain = 21.0;
        }
        return MarketTradeResult(
          success: true,
          consumed: {'furniture': 10.0},
          gained: {'stone': (gain * merchantBonus).roundToDouble()},
        );
      }
    } else if (recipeKey == 'iron_stone_to_crown') {
      final double cost = (season == 'AUTUMN') ? 20.0 : 25.0;
      if ((resources['iron'] ?? 0.0) >= cost &&
          (resources['stone'] ?? 0.0) >= cost) {
        return MarketTradeResult(
          success: true,
          consumed: {'iron': cost, 'stone': cost},
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

    final workerCoords = tiles
        .where((t) =>
            t.isOwned &&
            t.building != null &&
            (t.building!.type == BuildingType.worker ||
                t.building!.type == BuildingType.castle ||
                t.building!.type == BuildingType.fishermanHut))
        .map((t) => t.coord)
        .toList();

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

      final bool hasWorkers =
          workerCoords.any((wc) => t.coord.distanceTo(wc) <= 4);

      final double rate = (b.baseProductionRate * math.pow(1.5, b.level - 1)) *
          globalMultiplier;
      final double maxCap = rate * 30.0;

      switch (b.type) {
        case BuildingType.corn:
        case BuildingType.barley:
        case BuildingType.pasture:
        case BuildingType.orchard:
          gainedFood += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.lumberjack:
        case BuildingType.resinCamp:
          gainedWood += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.quarry:
          gainedStone += hasWorkers
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
        case BuildingType.reindeerSanctuary:
        case BuildingType.herbalistYurt:
          gainedFood += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.caravanserai:
          gainedBread += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.scribeWorkshop:
          gainedPlank += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.steamVent:
          gainedStone += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.obsidianForge:
        case BuildingType.permafrostDig:
          gainedStone += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          gainedIron += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          break;
        case BuildingType.celestialAnvil:
          gainedIron += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.shrine:
        case BuildingType.castle:
        case BuildingType.worker:
        case BuildingType.watchtower:
        case BuildingType.bridge:
        case BuildingType.fishermanHut:
        case BuildingType.oasisCistern:
        case BuildingType.astrolabe:
        case BuildingType.geothermalBath:
        case BuildingType.ancestralTotem:
        case BuildingType.prismaticResonator:
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
    Map<String, int> cumulativeBiomeCounts = const {},
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

      final double masteryMult = getBiomeMasteryMultiplier(
        biome: t.biome,
        cumulativeBiomeCounts: cumulativeBiomeCounts,
      );

      final double seasonalBoost = getSeasonalProductionBoost(
        season: season,
        buildingType: b.type,
      );

      final double rate = (b.baseProductionRate * math.pow(1.5, b.level - 1)) *
          totalMult *
          seasonalBoost *
          biomeSynergy *
          masteryMult;

      switch (b.type) {
        case BuildingType.corn:
        case BuildingType.barley:
        case BuildingType.pasture:
        case BuildingType.orchard:
          netFood += rate;
          break;
        case BuildingType.lumberjack:
        case BuildingType.resinCamp:
          netWood += rate;
          break;
        case BuildingType.quarry:
          netStone += rate;
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
        case BuildingType.reindeerSanctuary:
        case BuildingType.herbalistYurt:
          netFood += rate;
          break;
        case BuildingType.caravanserai:
          netBread += rate;
          break;
        case BuildingType.scribeWorkshop:
          netPlank += rate;
          break;
        case BuildingType.steamVent:
          netStone += rate;
          break;
        case BuildingType.obsidianForge:
        case BuildingType.permafrostDig:
          netStone += rate * 0.5;
          netIron += rate * 0.5;
          break;
        case BuildingType.celestialAnvil:
          netIron += rate;
          break;
        case BuildingType.shrine:
        case BuildingType.castle:
        case BuildingType.worker:
        case BuildingType.watchtower:
        case BuildingType.bridge:
        case BuildingType.fishermanHut:
        case BuildingType.oasisCistern:
        case BuildingType.astrolabe:
        case BuildingType.geothermalBath:
        case BuildingType.ancestralTotem:
        case BuildingType.prismaticResonator:
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

    // Doğal efsanevi biyom zemin bonusları
    switch (targetTile.biome) {
      case TileBiome.celestialCrater:
        synergy += 0.50; // Göksel Rezonans
        break;
      case TileBiome.kurganValley:
        synergy += 0.40; // Atalar Bereketi
        break;
      case TileBiome.crystalChasm:
        synergy += 0.45; // Kristal Harmonisi
        break;
      default:
        break;
    }

    final bool hasOasisCisternNeighbor = neighborTiles.any((n) => n.building?.type == BuildingType.oasisCistern);

    for (final neighbor in neighborTiles) {
      if (neighbor.isFog) continue;

      switch (neighbor.biome) {
        case TileBiome.wetland:
        case TileBiome.sea:
          // Sazlık / Deniz: Çiftliklere ve Değirmenlere +%30 Sulama Bereketi
          if (bType == BuildingType.corn ||
              bType == BuildingType.barley ||
              bType == BuildingType.orchard ||
              bType == BuildingType.windmill) {
            synergy += 0.30;
          }
          if (bType == BuildingType.pasture) {
            synergy += 0.25;
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
          if (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.obsidianForge) {
            synergy += 0.50;
          }
          // Orman binalarına kuruma/kül riski (-%15)
          if (bType == BuildingType.lumberjack ||
              bType == BuildingType.sawmill ||
              bType == BuildingType.resinCamp) {
            synergy -= 0.15;
          }
          break;

        case TileBiome.desert:
          // Çöl: Değirmen & Mobilyacıya +%40 İpek Yolu Ticaret Bonusu
          if (bType == BuildingType.windmill || bType == BuildingType.furniture) {
            synergy += 0.40;
          }
          // Çiftliklere kuraklık cezası (-%20), eğer komşuda Vaha Sarnıcı yoksa
          if ((bType == BuildingType.corn || bType == BuildingType.orchard) && !hasOasisCisternNeighbor) {
            synergy -= 0.20;
          }
          break;

        case TileBiome.mountain:
          // Dağ: Maden ve Taş Ocağına +%35 Zengin Damar Bonusu
          if (bType == BuildingType.mine || bType == BuildingType.quarry) {
            synergy += 0.35;
          }
          // Gözetleme Kulesine +%50 Rüzgar Siperi & Görüş
          if (bType == BuildingType.watchtower) {
            synergy += 0.50;
          }
          break;

        case TileBiome.forest:
          // Orman: Marangoz, Mobilyacı ve Katran Otağına +%25 Kereste Yakınlığı
          if (bType == BuildingType.sawmill ||
              bType == BuildingType.furniture ||
              bType == BuildingType.resinCamp ||
              bType == BuildingType.orchard) {
            synergy += 0.25;
          }
          break;

        case TileBiome.celestialCrater:
          synergy += 0.50; // Göksel Rezonans
          break;

        case TileBiome.kurganValley:
          synergy += 0.40; // Atalar Bereketi
          break;

        case TileBiome.crystalChasm:
          synergy += 0.45; // Kristal Harmonisi
          break;

        case TileBiome.tundra:
          // Tundra: Kışın soğuk cezası (-%25), ancak Arpa ve Madenlere dayanıklılık
          if (season.toUpperCase() == 'WINTER' || isZud) {
            if (bType == BuildingType.corn || bType == BuildingType.orchard) synergy -= 0.25;
            if (bType == BuildingType.barley) synergy += 0.15; // Soğuk dayanıklılığı
          }
          if (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.permafrostDig) {
            synergy += 0.25;
          }
          break;

        case TileBiome.meadow:
          // Çayır: Çiftliklere ve Otlaklara Verimli Toprak
          if (bType == BuildingType.corn || bType == BuildingType.barley) {
            synergy += 0.15;
          }
          if (bType == BuildingType.pasture) {
            synergy += 0.25;
          }
          break;
      }

      // Komşuda Vaha Sarnıcı varsa bereket ver
      if (neighbor.building?.type == BuildingType.oasisCistern) {
        synergy += 0.40;
      }
      // Komşuda Jeotermal Kaplıca varsa ayazı kır
      if (neighbor.building?.type == BuildingType.geothermalBath) {
        synergy += 0.35;
      }
      // Komşuda Obsidyen Dökümhanesi varsa alet dayanıklılığı ver
      if (neighbor.building?.type == BuildingType.obsidianForge &&
          (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.sawmill)) {
        synergy += 0.35;
      }
    }

    // Mevsimsel özel bina çarpanları
    if (bType == BuildingType.orchard) {
      if (season.toUpperCase() == 'SUMMER') synergy += 0.50;
      if (season.toUpperCase() == 'AUTUMN') synergy += 0.30;
      if (season.toUpperCase() == 'WINTER') synergy -= 0.35;
    } else if (bType == BuildingType.pasture) {
      if (season.toUpperCase() == 'AUTUMN') synergy += 0.25;
      if (season.toUpperCase() == 'SPRING') synergy += 0.15;
    } else if (bType == BuildingType.barley) {
      if (season.toUpperCase() == 'WINTER') synergy += 0.20;
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

    switch (targetTile.biome) {
      case TileBiome.celestialCrater:
        labels.add('+50% GÖKSEL CEVHER (Krater)');
        break;
      case TileBiome.kurganValley:
        labels.add('+40% ATALAR BEREKETİ (Kurgan)');
        break;
      case TileBiome.crystalChasm:
        labels.add('+45% KRİSTAL HARMONİSİ (Yarık)');
        break;
      default:
        break;
    }

    final bool hasOasisCisternNeighbor = neighborTiles.any((n) => n.building?.type == BuildingType.oasisCistern);
    if (hasOasisCisternNeighbor) {
      labels.add('+40% Vaha Sarnıcı Aurası');
    }

    for (final neighbor in neighborTiles) {
      if (neighbor.isFog) continue;

      switch (neighbor.biome) {
        case TileBiome.celestialCrater:
          labels.add('+50% Göksel Rezonans (Krater)');
          break;

        case TileBiome.kurganValley:
          labels.add('+40% Atalar Bereketi (Kurgan)');
          break;

        case TileBiome.crystalChasm:
          labels.add('+45% Kristal Harmonisi (Yarık)');
          break;

        case TileBiome.wetland:
        case TileBiome.sea:
          if (bType == BuildingType.corn ||
              bType == BuildingType.barley ||
              bType == BuildingType.orchard ||
              bType == BuildingType.windmill) {
            labels.add('+30% Sulama Bereketi (Su/Sazlık)');
          }
          if (bType == BuildingType.pasture) {
            labels.add('+25% Su Yalağı Bereketi (Su)');
          }
          if (bType == BuildingType.bakery ||
              bType == BuildingType.fisherman ||
              bType == BuildingType.fishermanHut) {
            labels.add('+20% Lojistik Kolaylığı (Deniz)');
          }
          break;

        case TileBiome.volcano:
          if (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.obsidianForge) {
            labels.add('+50% Jeotermal Dökümhane (Volkan)');
          }
          if (bType == BuildingType.lumberjack || bType == BuildingType.sawmill || bType == BuildingType.resinCamp) {
            labels.add('-15% Kül Kuruması (Volkan)');
          }
          break;

        case TileBiome.desert:
          if (bType == BuildingType.windmill ||
              bType == BuildingType.furniture ||
              bType == BuildingType.caravanserai) {
            labels.add('+40% İpek Yolu Ticareti (Çöl)');
          }
          if ((bType == BuildingType.corn || bType == BuildingType.orchard) && !hasOasisCisternNeighbor) {
            labels.add('-20% Kuraklık (Çöl)');
          }
          break;

        case TileBiome.mountain:
          if (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.astrolabe) {
            labels.add('+35% Zengin Damar & Taş (Dağ)');
          }
          if (bType == BuildingType.watchtower) {
            labels.add('+50% Rüzgar Siperi (Dağ)');
          }
          break;

        case TileBiome.forest:
          if (bType == BuildingType.sawmill ||
              bType == BuildingType.furniture ||
              bType == BuildingType.resinCamp ||
              bType == BuildingType.orchard) {
            labels.add('+25% Kereste & Huş Yakınlığı (Orman)');
          }
          break;

        case TileBiome.tundra:
          if (season.toUpperCase() == 'WINTER' || isZud) {
            if (bType == BuildingType.corn || bType == BuildingType.orchard) labels.add('-25% Ayaz Şoku (Tundra)');
            if (bType == BuildingType.barley) labels.add('+15% Soğuk Direnci (Arpa)');
          }
          if (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.permafrostDig) {
            labels.add('+25% Permafrost Damarı (Tundra)');
          }
          break;

        case TileBiome.meadow:
          if (bType == BuildingType.corn || bType == BuildingType.barley) {
            labels.add('+15% Verimli Toprak (Çayır)');
          }
          if (bType == BuildingType.pasture) {
            labels.add('+25% Bozkır Otu Bereketi (Çayır)');
          }
          break;
      }

      if (neighbor.building?.type == BuildingType.oasisCistern) {
        labels.add('+40% Vaha Sarnıcı Bereketi');
      }
      if (neighbor.building?.type == BuildingType.geothermalBath) {
        labels.add('+35% Jeotermal Isı Aurası');
      }
      if (neighbor.building?.type == BuildingType.obsidianForge &&
          (bType == BuildingType.mine || bType == BuildingType.quarry || bType == BuildingType.sawmill)) {
        labels.add('+35% Obsidyen Alet Gücü');
      }
    }

    if (bType == BuildingType.orchard) {
      if (season.toUpperCase() == 'SUMMER') labels.add('+50% Yaz Meyve Coşkusu');
      if (season.toUpperCase() == 'AUTUMN') labels.add('+30% Sonbahar Hasadı');
      if (season.toUpperCase() == 'WINTER') labels.add('-35% Kış Uykusu');
    } else if (bType == BuildingType.pasture) {
      if (season.toUpperCase() == 'AUTUMN') labels.add('+25% Sonbahar Besi Dönemi');
      if (season.toUpperCase() == 'SPRING') labels.add('+15% Bahar Yavrulama');
    } else if (bType == BuildingType.barley) {
      if (season.toUpperCase() == 'WINTER') labels.add('+20% Ayazda Dirençli Hasat');
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

  /// 1. Yaylak-Kışlak & Toprak Dinlendirme Çarpanı (Soil Health & Respiration Boost)
  static double calculateSoilHealthMultiplier(HexTileModel tile) {
    if (tile.isResting) {
      return 0.0; // Dinlenen arazi üretim yapmaz, enerji biriktirir
    }
    if (tile.restTimeAccumulated >= 10.0) {
      return 2.5; // Bereket Patlaması (Respiration Boost)
    }
    return (0.7 + 0.3 * tile.soilHealth.clamp(0.0, 1.0));
  }

  /// 2. Kervan İpek Yolu Takas Rezonansı (+25% Çarpan)
  static double calculateCaravanRouteMultiplier(HexAxial coord, List<CaravanRoute> routes) {
    final bool hasRoute = routes.any((r) => r.startCoord == coord || r.endCoord == coord);
    return hasRoute ? 1.25 : 1.0;
  }

  /// 3. Ekolojik Biyom Simbiyoz Çarpanı (+50% Çarpan)
  static double calculateSymbiosisMultiplier(HexTileModel tile) {
    return SymbiosisEngine.getSymbiosisMultiplier(tile.symbiosis);
  }

  /// 4. 12 Hayvanlı Göksel Alamet Kaynak Çarpanı
  static double calculateCelestialOmenMultiplier(CelestialOmen omen, {required String resourceType}) {
    switch (resourceType.toLowerCase()) {
      case 'wood':
        return omen.woodMultiplier;
      case 'meat':
      case 'food':
      case 'bread':
      case 'fish':
        return omen.meatMultiplier;
      case 'gold':
      case 'crowns':
        return omen.goldMultiplier;
      case 'iron':
      case 'stone':
      case 'obsidian':
        return omen.ironMultiplier;
      default:
        return 1.0;
    }
  }

  /// 5. Keşfedilen Ata Kurganları Prestij Mirası Çarpanı
  static double calculateAncestralRelicMultiplier(List<AncestralKurgan> kurgans) {
    double boost = 0.0;
    for (final kurgan in kurgans) {
      if (kurgan.isDiscovered) {
        boost += kurgan.bonusMultiplier;
      }
    }
    return 1.0 + boost;
  }

  /// 8. Dokunsal Ritim Ahenk Çarpanı (1.0x -> 3.0x)
  static double calculateRhythmComboMultiplier(int combo) {
    final int clamped = combo.clamp(0, 5);
    return 1.0 + (clamped * 0.4);
  }
}
