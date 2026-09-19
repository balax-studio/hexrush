import 'dart:math' as math;
import '../../core/hex/hex_coordinates.dart';
import '../../core/utils/number_formatter.dart';
import '../models/ad_reward_model.dart';
import '../models/ancestral_kurgan_model.dart';
import '../models/building_model.dart';
import '../models/caravan_route_model.dart';
import '../models/celestial_omen_model.dart';
import '../models/doctrine_model.dart';
import '../models/game_state_model.dart';
import '../models/hex_tile_model.dart';
import '../models/trade_order_model.dart';
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
  final double wisdom;
  final double kumis;
  final double felt;
  final double damascusSteel;

  // Lojistik yetersizliği sebebiyle taşınamayan üretim hızları (-x/sn)
  final double untransportedFood;
  final double untransportedWood;
  final double untransportedStone;
  final double untransportedIron;
  final double untransportedFlour;
  final double untransportedPlank;
  final double untransportedBread;
  final double untransportedFurniture;
  final double untransportedFish;
  final double untransportedWisdom;
  final double untransportedKumis;
  final double untransportedFelt;
  final double untransportedDamascusSteel;

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
    this.wisdom = 0.0,
    this.kumis = 0.0,
    this.felt = 0.0,
    this.damascusSteel = 0.0,
    this.untransportedFood = 0.0,
    this.untransportedWood = 0.0,
    this.untransportedStone = 0.0,
    this.untransportedIron = 0.0,
    this.untransportedFlour = 0.0,
    this.untransportedPlank = 0.0,
    this.untransportedBread = 0.0,
    this.untransportedFurniture = 0.0,
    this.untransportedFish = 0.0,
    this.untransportedWisdom = 0.0,
    this.untransportedKumis = 0.0,
    this.untransportedFelt = 0.0,
    this.untransportedDamascusSteel = 0.0,
  });
}

class WorkerLogisticsStats {
  final double totalCapacity;
  final double utilizedCapacity;
  final double utilizationRatio;
  final double demandInCoverage;
  final int coveredBuildingsCount;

  const WorkerLogisticsStats({
    required this.totalCapacity,
    required this.utilizedCapacity,
    required this.utilizationRatio,
    required this.demandInCoverage,
    required this.coveredBuildingsCount,
  });

  bool get isOverloaded => utilizationRatio >= 0.999 && totalCapacity > 0;
  double get idleCapacity => math.max(0.0, totalCapacity - utilizedCapacity);
}

class ResourceContributor {
  final BuildingType buildingType;
  final int level;
  final HexAxial coord;
  final double rate;
  final bool isProducer;
  final String? customLabel;
  final double untransportedRate;

  const ResourceContributor({
    required this.buildingType,
    required this.level,
    required this.coord,
    required this.rate,
    required this.isProducer,
    this.customLabel,
    this.untransportedRate = 0.0,
  });
}

class ResourceBreakdownStats {
  final List<ResourceContributor> producers;
  final List<ResourceContributor> consumers;
  final double totalProduction;
  final double totalConsumption;
  final double totalUntransported;

  const ResourceBreakdownStats({
    required this.producers,
    required this.consumers,
    required this.totalProduction,
    required this.totalConsumption,
    this.totalUntransported = 0.0,
  });

  double get netRate => totalProduction - totalConsumption;
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
  final double wisdom;
  final double kumis;
  final double felt;
  final double damascusSteel;

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
    this.wisdom = 0.0,
    this.kumis = 0.0,
    this.felt = 0.0,
    this.damascusSteel = 0.0,
  });

  OfflineGainsResult multipliedBy(double factor) {
    return OfflineGainsResult(
      seconds: seconds,
      food: food * factor,
      wood: wood * factor,
      flour: flour * factor,
      plank: plank * factor,
      bread: bread * factor,
      furniture: furniture * factor,
      stone: stone * factor,
      iron: iron * factor,
      fish: fish * factor,
      wisdom: wisdom * factor,
      kumis: kumis * factor,
      felt: felt * factor,
      damascusSteel: damascusSteel * factor,
    );
  }

  bool get hasGains =>
      food > 0 ||
      wood > 0 ||
      flour > 0 ||
      plank > 0 ||
      bread > 0 ||
      furniture > 0 ||
      stone > 0 ||
      iron > 0 ||
      fish > 0 ||
      wisdom > 0 ||
      kumis > 0 ||
      felt > 0 ||
      damascusSteel > 0;
}

class ResetCrownsBreakdown {
  final int hexCrowns;
  final int resourceCrowns;
  final int buildingAndShrineCrowns;
  final int totalCrowns;

  const ResetCrownsBreakdown({
    required this.hexCrowns,
    required this.resourceCrowns,
    required this.buildingAndShrineCrowns,
    required this.totalCrowns,
  });
}

/// Krallık Ekonomisi, Töre Ağacı & Yetenek Hesaplayıcı (Pure Dart Engine)
class EconomyCalculator {
  /// Kağan Otağı (Şato) Seviyesine Göre Toplam Küresel Üretim Yüzdesi (Bonus %)
  /// Seviye 1-9: Her seviye başına +%1
  /// Seviye 10-19: Her seviye başına +%2
  /// Seviye 20-29: Her seviye başına +%3
  /// Seviye 30-39: Her seviye başına +%4
  /// Seviye 40-49: Her seviye başına +%5
  /// Seviye 50+: Her seviye başına +%6 (Her 10 seviyede bir seviye başına gelen verim artışı +%1 yükselir)
  static double calculateCastleBonusPercentage(int castleLevel) {
    if (castleLevel <= 1) return 0.0;
    double totalPercent = 0.0;
    for (int lvl = 2; lvl <= castleLevel; lvl++) {
      final int stepRate = (lvl ~/ 10) + 1;
      totalPercent += stepRate;
    }
    return totalPercent;
  }

  static double getGlobalMultiplier({
    required int castleLevel,
    required int crowns,
    Map<String, dynamic> talents = const {},
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
    double kutMultiplier = 1.0,
  }) {
    final double castleBonusPercent = calculateCastleBonusPercentage(castleLevel);
    final double castleMult = 1.0 + (castleBonusPercent / 100.0);

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
        1.0 + talentBoost + toreBoost + titleBoost;
    return castleMult * prestigeMult * math.max(1.0, kutMultiplier);
  }

  /// Kut Katsayısı (Prestij / Büyük Göç Gelişim Çarpanı)
  /// Azalan verim modeliyle stabil, patlama yapmayan üstel güçlendirme sağlar.
  static double calculateKutMultiplier({
    required int tamgas,
    required int totalMigrations,
    Map<String, bool> victoryMilestones = const {},
    List<String> activeOaths = const [],
  }) {
    if (tamgas <= 0 && totalMigrations <= 0 && victoryMilestones.isEmpty) {
      return 1.0;
    }

    // 1. Tamga katkısı (Azalan verimle yumuşak katsayı)
    double tamgaBonus = 0.0;
    if (tamgas <= 50) {
      tamgaBonus = tamgas * 0.04;
    } else {
      tamgaBonus = 2.0 + (math.log(tamgas - 49.0) / math.ln10) * 0.5;
    }

    // 2. Kümülatif Büyük Göç Tecrübesi (+%5 her göçte)
    final double migrationBonus = totalMigrations * 0.05;

    // 3. Zafer Kilometre Taşları (+%25 kalıcı Kut her büyük zafer için)
    int victoryCount = 0;
    for (final v in victoryMilestones.values) {
      if (v) victoryCount++;
    }
    final double victoryBonus = victoryCount * 0.25;

    // 4. Kutsal Andlar (Meydan okumalar - and başına ekstra +%15)
    final double oathBonus = activeOaths.length * 0.15;

    return math.max(1.0, 1.0 + tamgaBonus + migrationBonus + victoryBonus + oathBonus);
  }

  /// Kültürel Zafer Kontrolü: 4 Cepheye Bengü Taş Dikme (Orhun Anıtları)
  static bool checkCulturalVictoryProgress({
    required ResourcesModel resources,
    required List<String> unlockedLoreIds,
  }) {
    return resources.wisdom >= 500.0 &&
        resources.damascusSteel >= 100.0 &&
        unlockedLoreIds.length >= 3;
  }

  /// Lojistik & Ticaret Zaferi: Ulu İpek Yolu Ağı
  static bool checkSilkRoadVictoryProgress({
    required List<CaravanRoute> routes,
    required ResourcesModel resources,
  }) {
    return routes.length >= 3 &&
        resources.kumis >= 100.0 &&
        resources.felt >= 100.0;
  }

  /// Coğrafi Zafer: 4 Kadim Diyarın Ehlileştirilmesi
  static bool checkRealmConquestProgress({
    required Map<String, int> cumulativeBiomeCounts,
    required int ownedCount,
  }) {
    final meadow = cumulativeBiomeCounts['meadow'] ?? 0;
    final forest = cumulativeBiomeCounts['forest'] ?? 0;
    final mountain = cumulativeBiomeCounts['mountain'] ?? 0;
    return ownedCount >= 20 && (meadow >= 4 && forest >= 4 && mountain >= 4);
  }

  /// Büyük Göç (Sıfırlama) anında kazanılacak Tamga miktarını hesaplar: (Fethedilen Karo + (Fethedilen Sunak * 5)) ~/ 2
  static int calculateMigrationTamgas({
    required int ownedCount,
    required int ownedShrinesCount,
  }) {
    return (ownedCount + (ownedShrinesCount * 5)) ~/ 2;
  }

  /// Büyük Göç (Sıfırlama) anında kazanılacak Taç miktarını ve detaylı dökümünü hesaplar (Dengeli Pacing Modeli)
  static ResetCrownsBreakdown calculateResetCrownsBreakdown({
    required Iterable<HexTileModel> tiles,
    required ResourcesModel resources,
    required int castleLevel,
  }) {
    int ownedHexCount = 0;
    int shrineCount = 0;
    int buildingLevelsTotal = 0;

    for (final tile in tiles) {
      if (tile.isOwned) {
        ownedHexCount++;
        if (tile.hasShrine) {
          shrineCount++;
        }
        if (tile.hasBuilding && tile.building!.type != BuildingType.castle) {
          buildingLevelsTotal += tile.building!.level;
        }
      }
    }

    // 1. Sahip olunan hex karolarından Taç (Her 5 karo = 1 Taç)
    final int hexCrowns = ownedHexCount ~/ 5;

    // 2. Ambar envanterindeki refah stoğundan Taç (Kademeli Refah Modeli)
    final double totalResourceStock = resources.food +
        resources.wood +
        resources.stone +
        resources.iron +
        resources.fish +
        resources.flour +
        resources.plank +
        resources.bread +
        resources.furniture +
        (resources.kumis * 2.0) +
        (resources.felt * 2.0) +
        (resources.damascusSteel * 3.0) +
        resources.wisdom;

    int resourceCrowns = 0;
    if (totalResourceStock >= 500000) {
      resourceCrowns = 4;
    } else if (totalResourceStock >= 100000) {
      resourceCrowns = 3;
    } else if (totalResourceStock >= 20000) {
      resourceCrowns = 2;
    } else if (totalResourceStock >= 5000) {
      resourceCrowns = 1;
    }

    // 3. Binalar, Şato ve Kadim Sunaklardan Taç
    // - Keşfedilen her Kadim Sunak: 1 Taç
    // - Kağan Otağı seviyesi: Her 2 seviyede 1 Taç (Sv.3 = 1, Sv.5 = 2 vb.)
    // - İnşa edilen her 15 bina kademesi: 1 Taç
    final int buildingAndShrineCrowns = shrineCount +
        (castleLevel ~/ 2) +
        (buildingLevelsTotal ~/ 15);

    final int totalCrowns = hexCrowns + resourceCrowns + buildingAndShrineCrowns;

    return ResetCrownsBreakdown(
      hexCrowns: hexCrowns,
      resourceCrowns: resourceCrowns,
      buildingAndShrineCrowns: buildingAndShrineCrowns,
      totalCrowns: totalCrowns,
    );
  }

  static double getWorkerTransferMultiplier({
    Map<String, dynamic> talents = const {},
    Map<String, dynamic> toreTalents = const {},
    int totalMigrations = 0,
  }) {
    final int speedLvl = (talents['workerSpeed'] as num? ?? 0).toInt();
    int roadLvl = 0;
    if (toreTalents.containsKey('tonyukuk')) {
      final tonyukuk = toreTalents['tonyukuk'] as Map<String, dynamic>;
      roadLvl = (tonyukuk['pavedRoads'] as num? ?? 0).toInt();
    }
    final double baseMultiplier = 1.0 + speedLvl * 0.10 + roadLvl * 0.08;
    final double migrationScaling = 1.0 + (totalMigrations * 0.35);
    return baseMultiplier * migrationScaling;
  }

  /// Haritadaki tüm işçi kulübeleri ve üretim binaları arasında dinamik greedy lojistik yük dağıtımı yapar.
  /// Çakışan menzillerde binaların yükünü en yakın kulübeye aktarır; kapasite yetmezse menzildeki diğer kulübeye devreder.
  static Map<HexAxial, WorkerLogisticsStats> calculateAllWorkerLogisticsStats({
    required Map<HexAxial, HexTileModel> tiles,
    double workerTransferMult = 1.0,
    double globalMultiplier = 1.0,
    double seasonMultiplier = 1.0,
    double shrineMultiplier = 1.0,
    String season = 'SPRING',
    bool isZud = false,
    Map<String, int> cumulativeBiomeCounts = const {},
    List<CaravanRoute> caravanRoutes = const [],
    List<DoctrineCardModel> activeDoctrines = const [],
    List<AncestralKurgan> discoveredKurgans = const [],
  }) {
    final Map<HexAxial, WorkerLogisticsStats> result = {};

    // 1. İşçi kulübelerini topla
    final List<HexTileModel> workerTiles = [];
    final Map<HexAxial, double> totalCapacities = {};
    final Map<HexAxial, double> remainingCapacities = {};
    final Map<HexAxial, double> assignedTransports = {};
    final Map<HexAxial, double> demandInCoverage = {};
    final Map<HexAxial, int> coveredCounts = {};

    for (final t in tiles.values) {
      if (!t.isOwned || t.building == null) continue;
      if (t.building!.type == BuildingType.worker) {
        workerTiles.add(t);
        final double cap = t.building!.currentCarryingCapacity * workerTransferMult;
        totalCapacities[t.coord] = cap;
        remainingCapacities[t.coord] = cap;
        assignedTransports[t.coord] = 0.0;
        demandInCoverage[t.coord] = 0.0;
        coveredCounts[t.coord] = 0;
      }
    }

    if (workerTiles.isEmpty) return result;

    // 2. Üretim binalarını ve brüt taleplerini belirle
    final Map<HexAxial, double> remainingProductionToTransport = {};
    final List<HexTileModel> producerTiles = [];

    for (final tile in tiles.values) {
      if (!tile.isOwned || tile.building == null) continue;
      final b = tile.building!;
      if (b.type == BuildingType.castle ||
          b.type == BuildingType.worker ||
          b.type == BuildingType.watchtower ||
          b.type == BuildingType.bridge ||
          b.type == BuildingType.fishermanHut ||
          b.type == BuildingType.granaryVault) {
        continue;
      }

      final double sMult = getSeasonProductionMultiplier(
        season: season,
        isZud: isZud,
        isTileWarmed: tile.isWarmed,
      );

      final double realRate = calculateTileEffectiveProductionRate(
        tile: tile,
        tileMap: tiles,
        globalMultiplier: globalMultiplier,
        seasonMultiplier: seasonMultiplier * sMult,
        shrineMultiplier: shrineMultiplier,
        season: season,
        isZud: isZud,
        cumulativeBiomeCounts: cumulativeBiomeCounts,
        activeDoctrines: activeDoctrines,
        caravanRoutes: caravanRoutes,
        discoveredKurgans: discoveredKurgans,
      );

      remainingProductionToTransport[tile.coord] = realRate;
      producerTiles.add(tile);

      // Kapsayan işçi kulübelerini tespit edip sayaçlara ekle
      for (final wt in workerTiles) {
        if (tile.coord.distanceTo(wt.coord) <= 4) {
          demandInCoverage[wt.coord] = (demandInCoverage[wt.coord] ?? 0.0) + realRate;
          coveredCounts[wt.coord] = (coveredCounts[wt.coord] ?? 0) + 1;
        }
      }
    }

    // 3. Greedy Dağıtım: Her üretim binası için menzildeki kulübeleri en yakından uzağa sıralayarak yükü paylaştır
    for (final pt in producerTiles) {
      double needed = remainingProductionToTransport[pt.coord] ?? 0.0;
      if (needed <= 0.0) continue;

      final inRangeWorkers = workerTiles
          .where((wt) => pt.coord.distanceTo(wt.coord) <= 4)
          .toList()
        ..sort((a, b) => pt.coord.distanceTo(a.coord).compareTo(pt.coord.distanceTo(b.coord)));

      for (final wt in inRangeWorkers) {
        if (needed <= 0.0) break;
        final double remCap = remainingCapacities[wt.coord] ?? 0.0;
        if (remCap > 0.0) {
          final double alloc = math.min(remCap, needed);
          remainingCapacities[wt.coord] = remCap - alloc;
          assignedTransports[wt.coord] = (assignedTransports[wt.coord] ?? 0.0) + alloc;
          needed -= alloc;
        }
      }
      remainingProductionToTransport[pt.coord] = needed;
    }

    // 4. Sonuçları oluştur
    for (final wt in workerTiles) {
      final double totalCap = totalCapacities[wt.coord] ?? 0.0;
      final double assigned = assignedTransports[wt.coord] ?? 0.0;
      final double rawRatio = totalCap > 0.0 ? (assigned / totalCap).clamp(0.0, 1.0) : 0.0;
      final double utilRatio = (rawRatio - 1.0).abs() < 0.0001 ? 1.0 : rawRatio;

      result[wt.coord] = WorkerLogisticsStats(
        totalCapacity: totalCap,
        utilizedCapacity: assigned,
        utilizationRatio: utilRatio,
        demandInCoverage: demandInCoverage[wt.coord] ?? 0.0,
        coveredBuildingsCount: coveredCounts[wt.coord] ?? 0,
      );
    }

    return result;
  }

  static WorkerLogisticsStats calculateWorkerLogisticsStats({
    required HexTileModel workerTile,
    required Map<HexAxial, HexTileModel> tiles,
    double workerTransferMult = 1.0,
    double globalMultiplier = 1.0,
    double seasonMultiplier = 1.0,
    double shrineMultiplier = 1.0,
    String season = 'SPRING',
    bool isZud = false,
    Map<String, int> cumulativeBiomeCounts = const {},
    List<CaravanRoute> caravanRoutes = const [],
    List<DoctrineCardModel> activeDoctrines = const [],
    List<AncestralKurgan> discoveredKurgans = const [],
  }) {
    if (workerTile.building == null) {
      return const WorkerLogisticsStats(
        totalCapacity: 0.0,
        utilizedCapacity: 0.0,
        utilizationRatio: 0.0,
        demandInCoverage: 0.0,
        coveredBuildingsCount: 0,
      );
    }

    final allStats = calculateAllWorkerLogisticsStats(
      tiles: tiles,
      workerTransferMult: workerTransferMult,
      globalMultiplier: globalMultiplier,
      seasonMultiplier: seasonMultiplier,
      shrineMultiplier: shrineMultiplier,
      season: season,
      isZud: isZud,
      cumulativeBiomeCounts: cumulativeBiomeCounts,
      caravanRoutes: caravanRoutes,
      activeDoctrines: activeDoctrines,
      discoveredKurgans: discoveredKurgans,
    );

    return allStats[workerTile.coord] ??
        WorkerLogisticsStats(
          totalCapacity: workerTile.building!.currentCarryingCapacity * workerTransferMult,
          utilizedCapacity: 0.0,
          utilizationRatio: 0.0,
          demandInCoverage: 0.0,
          coveredBuildingsCount: 0,
        );
  }

  static ResourceBreakdownStats calculateResourceBreakdown({
    required String resourceKey,
    required Map<HexAxial, HexTileModel> tiles,
    required int castleLevel,
    required int crowns,
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
    double kutMultiplier = 1.0,
    String season = 'SPRING',
    bool isZud = false,
    List<DoctrineCardModel> activeDoctrines = const [],
    List<CaravanRoute> caravanRoutes = const [],
    CelestialOmen? celestialOmen,
    List<AncestralKurgan> discoveredKurgans = const [],
    double shrineMultiplier = 1.0,
    List<String> unlockedLoreIds = const [],
    Map<String, int> cumulativeBiomeCounts = const {},
    int frenzyMultiplier = 1,
    double seasonMultiplier = 1.0,
    int totalMigrations = 0,
  }) {
    final String rKey = resourceKey.toLowerCase().replaceAll('_', '');
    final List<ResourceContributor> producers = [];
    final List<ResourceContributor> consumers = [];

    final double globalMult = getGlobalMultiplier(
      castleLevel: castleLevel,
      crowns: crowns,
      toreTalents: toreTalents,
      titles: titles,
      kutMultiplier: kutMultiplier,
    );

    // Doktrin: Göçer İaşesi (Boş çayırlardan iaşe)
    if (rKey == 'food' &&
        activeDoctrines.any((d) => d.effectType == DoctrineEffectType.meadowGrazeYield)) {
      int emptyMeadows = 0;
      for (final t in tiles.values) {
        if (t.isOwned && t.biome == TileBiome.meadow && !t.hasBuilding) {
          emptyMeadows++;
        }
      }
      if (emptyMeadows > 0) {
        producers.add(ResourceContributor(
          buildingType: BuildingType.pasture,
          level: 1,
          coord: const HexAxial(0, 0),
          rate: emptyMeadows * 0.5,
          isProducer: true,
          customLabel: 'Göçer İaşesi ($emptyMeadows Çayır)',
        ));
      }
    }

    for (final tile in tiles.values) {
      if (!tile.isOwned || tile.building == null) continue;
      final b = tile.building!;

      if (b.type == BuildingType.castle ||
          b.type == BuildingType.worker ||
          b.type == BuildingType.watchtower ||
          b.type == BuildingType.bridge ||
          b.type == BuildingType.fishermanHut ||
          b.type == BuildingType.granaryVault) {
        continue;
      }

      final double rate = calculateTileEffectiveProductionRate(
        tile: tile,
        tileMap: tiles,
        globalMultiplier: globalMult,
        seasonMultiplier: seasonMultiplier,
        shrineMultiplier: shrineMultiplier,
        season: season,
        isZud: isZud,
        cumulativeBiomeCounts: cumulativeBiomeCounts,
        activeDoctrines: activeDoctrines,
        caravanRoutes: caravanRoutes,
        celestialOmen: celestialOmen,
        discoveredKurgans: discoveredKurgans,
        frenzyMultiplier: frenzyMultiplier,
        titles: titles,
      );

      // Üretici Eşleşmeleri
      if (rKey == 'food') {
        if (b.type == BuildingType.corn ||
            b.type == BuildingType.barley ||
            b.type == BuildingType.pasture ||
            b.type == BuildingType.orchard ||
            b.type == BuildingType.fisherman ||
            b.type == BuildingType.oasisCistern ||
            b.type == BuildingType.reindeerSanctuary ||
            b.type == BuildingType.herbalistYurt) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
        if (b.type == BuildingType.windmill) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.5,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.bakery) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.4,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.kumisYurt) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 1.0,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.feltTentWorkshop) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.5,
            isProducer: false,
          ));
        }
      } else if (rKey == 'wood') {
        if (b.type == BuildingType.lumberjack || b.type == BuildingType.resinCamp) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
        if (b.type == BuildingType.sawmill) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.5,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.furniture) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.4,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.feltTentWorkshop) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.5,
            isProducer: false,
          ));
        } else if (b.type == BuildingType.damascusForge) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.5,
            isProducer: false,
          ));
        }
      } else if (rKey == 'flour') {
        if (b.type == BuildingType.windmill) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
        if (b.type == BuildingType.bakery) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.4,
            isProducer: false,
          ));
        }
      } else if (rKey == 'plank') {
        if (b.type == BuildingType.sawmill || b.type == BuildingType.scribeWorkshop) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
        if (b.type == BuildingType.furniture) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate * 0.4,
            isProducer: false,
          ));
        }
      } else if (rKey == 'bread') {
        if (b.type == BuildingType.bakery || b.type == BuildingType.caravanserai) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
      } else if (rKey == 'furniture') {
        if (b.type == BuildingType.furniture) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
      } else if (rKey == 'stone') {
        if (b.type == BuildingType.quarry || b.type == BuildingType.mine || b.type == BuildingType.steamVent) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
      } else if (rKey == 'iron') {
        if (b.type == BuildingType.mine ||
            b.type == BuildingType.permafrostDig ||
            b.type == BuildingType.obsidianForge ||
            b.type == BuildingType.celestialAnvil) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
        if (b.type == BuildingType.damascusForge) {
          consumers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.5,
            isProducer: false,
          ));
        }
      } else if (rKey == 'fish') {
        if (b.type == BuildingType.fisherman) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
      } else if (rKey == 'kumis') {
        if (b.type == BuildingType.kumisYurt) {
          final double soilMult = unlockedLoreIds.contains('lore_soil_2') ? 1.35 : 1.0;
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.25 * globalMult * soilMult,
            isProducer: true,
          ));
        }
      } else if (rKey == 'felt') {
        if (b.type == BuildingType.feltTentWorkshop) {
          final double weatherMult = unlockedLoreIds.contains('lore_weather_2') ? 1.40 : 1.0;
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.22 * globalMult * weatherMult,
            isProducer: true,
          ));
        }
      } else if (rKey == 'damascussteel' || rKey == 'damascus') {
        if (b.type == BuildingType.damascusForge) {
          final double metalMult = unlockedLoreIds.contains('lore_metal_2') ? 1.50 : 1.0;
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: 0.18 * globalMult * metalMult,
            isProducer: true,
          ));
        }
      } else if (rKey == 'wisdom' || rKey == 'lore') {
        if (b.type == BuildingType.runicStele || b.type == BuildingType.astrolabe) {
          producers.add(ResourceContributor(
            buildingType: b.type,
            level: b.level,
            coord: tile.coord,
            rate: rate,
            isProducer: true,
          ));
        }
      }
    }

    // Lojistik Taşıma Kapasitesi Dağıtımı (allocateGreedyLogistics ile Tek Doğruluk Kaynağı)
    final double workerTransferMult = getWorkerTransferMultiplier(
      toreTalents: toreTalents,
      totalMigrations: totalMigrations,
    );

    final Map<HexAxial, double> producerDemands = {for (final p in producers) p.coord: p.rate};
    final Map<HexAxial, double> untransportedByCoord = allocateGreedyLogistics(
      tiles: tiles,
      producerDemands: producerDemands,
      workerTransferMult: workerTransferMult,
    );

    final List<ResourceContributor> finalProducers = [];
    double totalUntransported = 0.0;

    for (final prod in producers) {
      final double untransported = untransportedByCoord[prod.coord] ?? 0.0;
      totalUntransported += untransported;
      finalProducers.add(ResourceContributor(
        buildingType: prod.buildingType,
        level: prod.level,
        coord: prod.coord,
        rate: prod.rate,
        isProducer: prod.isProducer,
        customLabel: prod.customLabel,
        untransportedRate: untransported,
      ));
    }

    // Sıralama (En yüksek katkı en başta)
    finalProducers.sort((a, b) => b.rate.compareTo(a.rate));
    consumers.sort((a, b) => b.rate.compareTo(a.rate));

    final double totalProd = finalProducers.fold(0.0, (sum, p) => sum + p.rate);
    final double totalCons = consumers.fold(0.0, (sum, c) => sum + c.rate);

    return ResourceBreakdownStats(
      producers: finalProducers,
      consumers: consumers,
      totalProduction: totalProd,
      totalConsumption: totalCons,
      totalUntransported: totalUntransported,
    );
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
    final Map<String, double> costs = {};

    // 1. Gıda (Food): Başlangıçtan itibaren her seviyede katlanarak artar
    final double foodCost = 50.0 * math.pow(1.5, math.max(0, nextLevel - 2));
    costs['food'] = foodCost;

    // 2. Odun (Wood): Şato 2. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 3)
    if (nextLevel >= 3) {
      costs['wood'] = 25.0 * math.pow(1.5, nextLevel - 3);
    }

    // 3. Taş, Un, Kalas, Bilgelik: Şato 5. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 6)
    if (nextLevel >= 6) {
      costs['stone'] = 20.0 * math.pow(1.5, nextLevel - 6);
      costs['flour'] = 15.0 * math.pow(1.5, nextLevel - 6);
      costs['plank'] = 15.0 * math.pow(1.5, nextLevel - 6);
      costs['wisdom'] = 10.0 * math.pow(1.5, nextLevel - 6);
    }

    // 4. Demir, Ekmek, Balık: Şato 15. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 16)
    if (nextLevel >= 16) {
      costs['iron'] = 15.0 * math.pow(1.5, nextLevel - 16);
      costs['bread'] = 15.0 * math.pow(1.5, nextLevel - 16);
      costs['fish'] = 20.0 * math.pow(1.5, nextLevel - 16);
    }

    // 5. Mobilya, Keçe: Şato 20. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 21)
    if (nextLevel >= 21) {
      costs['furniture'] = 10.0 * math.pow(1.5, nextLevel - 21);
      costs['felt'] = 10.0 * math.pow(1.5, nextLevel - 21);
    }

    // 6. Kımız: Şato 30. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 31)
    if (nextLevel >= 31) {
      costs['kumis'] = 10.0 * math.pow(1.5, nextLevel - 31);
    }

    // 7. Obsidiyen, Şam Çeliği: Şato 40. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 41)
    if (nextLevel >= 41) {
      costs['obsidian'] = 5.0 * math.pow(1.5, nextLevel - 41);
      costs['damascusSteel'] = 5.0 * math.pow(1.5, nextLevel - 41);
    }

    // 8. Mithril: Şato 45. seviyeye ulaştıktan sonraki seviyelerde (nextLevel >= 46)
    if (nextLevel >= 46) {
      costs['mithril'] = 5.0 * math.pow(1.5, nextLevel - 46);
    }

    return costs;
  }

  /// Şato yükseltmesi için gerekli tüm kaynakların mevcut olup olmadığını kontrol eder
  static bool canAffordCastleUpgrade(ResourcesModel resources, int nextLevel) {
    final costs = getCastleUpgradeCost(nextLevel);
    for (final entry in costs.entries) {
      final key = entry.key;
      final requiredAmount = entry.value;
      if (requiredAmount <= 0) continue;
      final double available = getResourceAmount(resources, key);
      if (available < requiredAmount) return false;
    }
    return true;
  }

  /// Kaynak modelinden dinamik anahtara göre miktarı çeker
  static double getResourceAmount(ResourcesModel resources, String key) {
    switch (key) {
      case 'food':
        return resources.food;
      case 'wood':
        return resources.wood;
      case 'stone':
        return resources.stone;
      case 'iron':
        return resources.iron;
      case 'flour':
        return resources.flour;
      case 'plank':
        return resources.plank;
      case 'bread':
        return resources.bread;
      case 'furniture':
        return resources.furniture;
      case 'fish':
        return resources.fish;
      case 'wisdom':
        return resources.wisdom;
      case 'kumis':
        return resources.kumis;
      case 'felt':
        return resources.felt;
      case 'obsidian':
        return resources.obsidian;
      case 'damascusSteel':
        return resources.damascusSteel;
      case 'mithril':
        return resources.mithril;
      default:
        return 0.0;
    }
  }

  /// Şato geliştirme maliyetlerini kaynak modelinden düşer
  static ResourcesModel deductCastleUpgradeCost(ResourcesModel resources, int nextLevel) {
    final costs = getCastleUpgradeCost(nextLevel);
    return resources.copyWith(
      food: math.max(0.0, resources.food - (costs['food'] ?? 0.0)),
      wood: math.max(0.0, resources.wood - (costs['wood'] ?? 0.0)),
      stone: math.max(0.0, resources.stone - (costs['stone'] ?? 0.0)),
      iron: math.max(0.0, resources.iron - (costs['iron'] ?? 0.0)),
      flour: math.max(0.0, resources.flour - (costs['flour'] ?? 0.0)),
      plank: math.max(0.0, resources.plank - (costs['plank'] ?? 0.0)),
      bread: math.max(0.0, resources.bread - (costs['bread'] ?? 0.0)),
      furniture: math.max(0.0, resources.furniture - (costs['furniture'] ?? 0.0)),
      fish: math.max(0.0, resources.fish - (costs['fish'] ?? 0.0)),
      wisdom: math.max(0.0, resources.wisdom - (costs['wisdom'] ?? 0.0)),
      kumis: math.max(0.0, resources.kumis - (costs['kumis'] ?? 0.0)),
      felt: math.max(0.0, resources.felt - (costs['felt'] ?? 0.0)),
      obsidian: math.max(0.0, resources.obsidian - (costs['obsidian'] ?? 0.0)),
      damascusSteel: math.max(0.0, resources.damascusSteel - (costs['damascusSteel'] ?? 0.0)),
      mithril: math.max(0.0, resources.mithril - (costs['mithril'] ?? 0.0)),
    );
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
    final int k = BuildingModel.getMilestoneTier(level);

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

  /// Tek bir karodaki binanın tüm küresel, mevsimsel, sinerji, töre, doktrin ve kervan çarpanlarıyla net debisini hesaplar.
  /// (Tüm alt hesaplayıcılar ve UI panelleri için Tek Doğruluk Kaynağı - Single Source of Truth)
  static double calculateTileEffectiveProductionRate({
    required HexTileModel tile,
    required Map<HexAxial, HexTileModel> tileMap,
    required double globalMultiplier,
    double seasonMultiplier = 1.0,
    double shrineMultiplier = 1.0,
    String season = 'SPRING',
    bool isZud = false,
    Map<String, int> cumulativeBiomeCounts = const {},
    List<DoctrineCardModel> activeDoctrines = const [],
    List<CaravanRoute> caravanRoutes = const [],
    CelestialOmen? celestialOmen,
    List<AncestralKurgan> discoveredKurgans = const [],
    int frenzyMultiplier = 1,
    Map<String, dynamic> titles = const {},
  }) {
    if (!tile.isOwned || !tile.hasBuilding) return 0.0;
    final b = tile.building!;

    if (b.type == BuildingType.castle ||
        b.type == BuildingType.worker ||
        b.type == BuildingType.watchtower ||
        b.type == BuildingType.bridge ||
        b.type == BuildingType.fishermanHut ||
        b.type == BuildingType.granaryVault) {
      return 0.0;
    }

    double chainSynergy = 1.0;
    for (final nCoord in tile.coord.neighbors) {
      final nTile = tileMap[nCoord];
      if (nTile != null && nTile.isOwned && nTile.building != null) {
        if (b.type == BuildingType.windmill && nTile.building!.type == BuildingType.corn) chainSynergy = 2.0;
        if (b.type == BuildingType.sawmill && nTile.building!.type == BuildingType.lumberjack) chainSynergy = 2.0;
        if (b.type == BuildingType.bakery && nTile.building!.type == BuildingType.windmill) chainSynergy = 2.0;
        if (b.type == BuildingType.furniture && nTile.building!.type == BuildingType.sawmill) chainSynergy = 2.0;
      }
    }

    final neighborTiles = tile.coord.neighbors
        .map((nc) => tileMap[nc])
        .whereType<HexTileModel>()
        .toList();

    final double biomeSynergy = calculateAdjacencySynergy(
      targetTile: tile,
      neighborTiles: neighborTiles,
      season: season,
      isZud: isZud,
    );

    final double masteryMult = getBiomeMasteryMultiplier(
      biome: tile.biome,
      cumulativeBiomeCounts: cumulativeBiomeCounts,
    );

    final double seasonalBoost = getSeasonalProductionBoost(
      season: season,
      buildingType: b.type,
    );

    final double docMult = getDoctrineProductionMultiplier(
      buildingType: b.type,
      activeDoctrines: activeDoctrines,
    );

    final double soilMult = calculateSoilHealthMultiplier(tile);
    final double caravanMult = calculateCaravanRouteMultiplier(tile.coord, caravanRoutes);
    final double symbiosisMult = calculateSymbiosisMultiplier(tile);
    final double ancestralMult = calculateAncestralRelicMultiplier(discoveredKurgans);
    final double omenMult = celestialOmen != null
        ? calculateCelestialOmenMultiplier(
            celestialOmen,
            resourceType: b.type == BuildingType.lumberjack || b.type == BuildingType.sawmill
                ? 'wood'
                : b.type == BuildingType.mine || b.type == BuildingType.quarry
                    ? 'iron'
                    : 'food',
          )
        : 1.0;

    final double warmedMultiplier = tile.isWarmed ? 1.50 : 1.0;
    final double effectiveSeasonMultiplier = seasonMultiplier * soilMult * warmedMultiplier;

    return calculateBuildingProduction(
      type: b.type,
      level: b.level,
      baseRate: b.baseProductionRate,
      globalMultiplier: globalMultiplier * docMult * caravanMult * symbiosisMult * ancestralMult * omenMult,
      seasonMultiplier: effectiveSeasonMultiplier,
      synergyMultiplier: chainSynergy * biomeSynergy,
      workerMultiplier: 1.0,
      shrineMultiplier: shrineMultiplier,
      biomeMasteryMultiplier: masteryMult,
      seasonalBoostMultiplier: seasonalBoost,
    );
  }

  /// Haritadaki üretim binaları ile işçi/şato depoları arasında en yakın menzilli greedy yük tahsisi yapar.
  /// Binaların taşınan ve taşınamayan (`untransported`) debilerini hesaplar.
  static Map<HexAxial, double> allocateGreedyLogistics({
    required Map<HexAxial, HexTileModel> tiles,
    required Map<HexAxial, double> producerDemands,
    double workerTransferMult = 1.0,
  }) {
    final Map<HexAxial, double> remainingDemand = Map.from(producerDemands);
    final List<HexAxial> workerSourceCoords = [];
    final List<double> workerSourceCapacities = [];

    for (final t in tiles.values) {
      if (!t.isOwned || t.building == null) continue;
      if (t.building!.type == BuildingType.castle) {
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(1.0 * workerTransferMult);
      } else if (t.building!.type == BuildingType.worker ||
          t.building!.type == BuildingType.fishermanHut ||
          t.building!.type == BuildingType.granaryVault) {
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(t.building!.currentCarryingCapacity * workerTransferMult);
      }
    }

    if (workerSourceCoords.isEmpty) {
      return remainingDemand;
    }

    for (final entry in producerDemands.entries) {
      final HexAxial pCoord = entry.key;
      double needed = entry.value;
      if (needed <= 0.0) continue;

      final inRangeIndices = <int>[];
      for (int i = 0; i < workerSourceCoords.length; i++) {
        if (pCoord.distanceTo(workerSourceCoords[i]) <= 4 && workerSourceCapacities[i] > 0.0) {
          inRangeIndices.add(i);
        }
      }
      inRangeIndices.sort((a, b) =>
          pCoord.distanceTo(workerSourceCoords[a]).compareTo(pCoord.distanceTo(workerSourceCoords[b])));

      for (final idx in inRangeIndices) {
        if (needed <= 0.0) break;
        if (workerSourceCapacities[idx] > 0.0) {
          final double take = math.min(needed, workerSourceCapacities[idx]);
          workerSourceCapacities[idx] -= take;
          needed -= take;
        }
      }
      remainingDemand[pCoord] = math.max(0.0, needed);
    }

    return remainingDemand;
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

  static const int minAfkSeconds = 60;
  static const int maxAfkSeconds = 8 * 3600; // 8 hours max (28800)

  static OfflineGainsResult calculateOfflineGains({
    required List<HexTileModel> tiles,
    required double elapsedSeconds,
    required double globalMultiplier,
    double minThresholdSeconds = 60.0,
  }) {
    const double maxOfflineSeconds = 8 * 3600.0;
    final double rawSeconds = math.max(0.0, elapsedSeconds);
    if (rawSeconds < minThresholdSeconds) {
      return const OfflineGainsResult(seconds: 0);
    }
    final double clampedSeconds = rawSeconds.clamp(0.0, maxOfflineSeconds);
    // 1-2 Saatlik Altın Pencere (Golden Retention Window):
    // İlk 2 saat (7200s) %100 üretim verimi ile ambar dolar.
    // 2-8 saat arasında kademeli mahzen tamponu (silo kapasitesi) devreye girer.
    double effectiveSeconds;
    if (clampedSeconds <= 7200.0) {
      effectiveSeconds = clampedSeconds;
    } else {
      final double excess = clampedSeconds - 7200.0;
      effectiveSeconds = 7200.0 + (excess * 0.60);
    }
    final double cappedSeconds = effectiveSeconds;

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
    double gainedWisdom = 0.0;
    double gainedKumis = 0.0;
    double gainedFelt = 0.0;
    double gainedDamascusSteel = 0.0;

    for (final t in tiles) {
      final b = t.building;
      if (b == null) continue;

      final bool hasWorkers =
          workerCoords.any((wc) => t.coord.distanceTo(wc) <= 4);

      final double rate = calculateBuildingProduction(
        type: b.type,
        level: b.level,
        baseRate: b.baseProductionRate,
        globalMultiplier: globalMultiplier,
      );
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
              ? (rate * 0.3) * cappedSeconds
              : math.min(maxCap * 0.3, (rate * 0.3) * cappedSeconds);
          break;
        case BuildingType.fisherman:
          gainedFish += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.oasisCistern:
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
          gainedFood += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          break;
        case BuildingType.scribeWorkshop:
          gainedPlank += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.geothermalBath:
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
          gainedStone += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          gainedIron += hasWorkers
              ? (rate * 0.5) * cappedSeconds
              : math.min(maxCap * 0.5, (rate * 0.5) * cappedSeconds);
          break;
        case BuildingType.astrolabe:
        case BuildingType.ancestralTotem:
        case BuildingType.prismaticResonator:
          gainedFood += hasWorkers
              ? (rate * 0.4) * cappedSeconds
              : math.min(maxCap * 0.4, (rate * 0.4) * cappedSeconds);
          gainedWood += hasWorkers
              ? (rate * 0.4) * cappedSeconds
              : math.min(maxCap * 0.4, (rate * 0.4) * cappedSeconds);
          gainedStone += hasWorkers
              ? (rate * 0.4) * cappedSeconds
              : math.min(maxCap * 0.4, (rate * 0.4) * cappedSeconds);
          break;
        case BuildingType.kumisYurt:
          gainedKumis += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.feltTentWorkshop:
          gainedFelt += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.damascusForge:
          gainedDamascusSteel += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.runicStele:
          gainedWisdom += hasWorkers
              ? rate * cappedSeconds
              : math.min(maxCap, rate * cappedSeconds);
          break;
        case BuildingType.granaryVault:
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
      wisdom: gainedWisdom,
      kumis: gainedKumis,
      felt: gainedFelt,
      damascusSteel: gainedDamascusSteel,
    );
  }

  /// Anlık Saniyelik Brüt Üretim Debisi (HUD Rozetleri ve Analitik için)
  static NetResourceRates calculateNetRates({
    required Iterable<HexTileModel> tiles,
    required double globalMultiplier,
    required double seasonMultiplier,
    required double shrineMultiplier,
    Map<HexAxial, HexTileModel>? tileMap,
    String season = 'SPRING',
    bool isZud = false,
    Map<String, int> cumulativeBiomeCounts = const {},
    List<DoctrineCardModel> activeDoctrines = const [],
    List<CaravanRoute> caravanRoutes = const [],
    CelestialOmen? celestialOmen,
    List<AncestralKurgan> discoveredKurgans = const [],
    Map<String, dynamic> titles = const {},
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> talents = const {},
    int totalMigrations = 0,
  }) {
    double netFood = 0.0;
    double netWood = 0.0;
    double netStone = 0.0;
    double netIron = 0.0;
    double netFlour = 0.0;
    double netPlank = 0.0;
    double netBread = 0.0;
    double netFurniture = 0.0;
    double netFish = 0.0;
    double netWisdom = 0.0;
    double netKumis = 0.0;
    double netFelt = 0.0;
    double netDamascusSteel = 0.0;

    double untransportedFood = 0.0;
    double untransportedWood = 0.0;
    double untransportedStone = 0.0;
    double untransportedIron = 0.0;
    double untransportedFlour = 0.0;
    double untransportedPlank = 0.0;
    double untransportedBread = 0.0;
    double untransportedFurniture = 0.0;
    double untransportedFish = 0.0;
    double untransportedWisdom = 0.0;
    double untransportedKumis = 0.0;
    double untransportedFelt = 0.0;
    double untransportedDamascusSteel = 0.0;

    final map = tileMap ?? {for (final t in tiles) t.coord: t};

    // İşçi ve Şato Taşıma Kaynakları (4 Hex Menzil)
    final double workerTransferMult = getWorkerTransferMultiplier(
      talents: talents,
      toreTalents: toreTalents,
      totalMigrations: totalMigrations,
    );
    final List<HexAxial> workerSourceCoords = [];
    final List<double> workerSourceCapacities = [];

    for (final t in tiles) {
      if (!t.isOwned || t.building == null) continue;
      if (t.building!.type == BuildingType.castle) {
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(1.0 * workerTransferMult);
      } else if (t.building!.type == BuildingType.worker ||
          t.building!.type == BuildingType.fishermanHut ||
          t.building!.type == BuildingType.granaryVault) {
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(t.building!.currentCarryingCapacity * workerTransferMult);
      }
    }

    if (activeDoctrines.any((d) => d.effectType == DoctrineEffectType.meadowGrazeYield)) {
      int emptyMeadows = 0;
      for (final t in tiles) {
        if (t.isOwned && t.biome == TileBiome.meadow && !t.hasBuilding) {
          emptyMeadows++;
        }
      }
      netFood += emptyMeadows * 0.5;
    }

    // 1. Tüm binaların üretim debilerini hesapla (Tek Doğruluk Kaynağı)
    final Map<HexAxial, double> buildingRates = {};
    for (final t in tiles) {
      if (!t.isOwned || !t.hasBuilding) continue;
      final double r = calculateTileEffectiveProductionRate(
        tile: t,
        tileMap: map,
        globalMultiplier: globalMultiplier,
        seasonMultiplier: seasonMultiplier,
        shrineMultiplier: shrineMultiplier,
        season: season,
        isZud: isZud,
        cumulativeBiomeCounts: cumulativeBiomeCounts,
        activeDoctrines: activeDoctrines,
        caravanRoutes: caravanRoutes,
        celestialOmen: celestialOmen,
        discoveredKurgans: discoveredKurgans,
        titles: titles,
      );
      if (r > 0.0) {
        buildingRates[t.coord] = r;
      }
    }

    // 2. Greedy Lojistik Tahsisi (En Yakın Depoya / İşçiye Dağıtım)
    final Map<HexAxial, double> untransportedByCoord = allocateGreedyLogistics(
      tiles: map,
      producerDemands: buildingRates,
      workerTransferMult: workerTransferMult,
    );

    for (final t in tiles) {
      if (!t.isOwned || !t.hasBuilding) continue;
      final b = t.building!;
      final double rate = buildingRates[t.coord] ?? 0.0;
      final double untransportedRate = untransportedByCoord[t.coord] ?? 0.0;

      switch (b.type) {
        case BuildingType.corn:
        case BuildingType.barley:
        case BuildingType.pasture:
        case BuildingType.orchard:
          netFood += rate;
          untransportedFood += untransportedRate;
          break;
        case BuildingType.lumberjack:
        case BuildingType.resinCamp:
          netWood += rate;
          untransportedWood += untransportedRate;
          break;
        case BuildingType.quarry:
          netStone += rate;
          untransportedStone += untransportedRate;
          break;
        case BuildingType.windmill:
          netFlour += rate;
          untransportedFlour += untransportedRate;
          break;
        case BuildingType.sawmill:
          netPlank += rate;
          untransportedPlank += untransportedRate;
          break;
        case BuildingType.bakery:
          netBread += rate;
          untransportedBread += untransportedRate;
          break;
        case BuildingType.furniture:
          netFurniture += rate;
          untransportedFurniture += untransportedRate;
          break;
        case BuildingType.mine:
          netStone += rate;
          netIron += rate * 0.3;
          untransportedStone += untransportedRate;
          untransportedIron += untransportedRate * 0.3;
          break;
        case BuildingType.fisherman:
          netFish += rate;
          untransportedFish += untransportedRate;
          break;
        case BuildingType.oasisCistern:
        case BuildingType.reindeerSanctuary:
        case BuildingType.herbalistYurt:
          netFood += rate;
          untransportedFood += untransportedRate;
          break;
        case BuildingType.caravanserai:
          netBread += rate;
          netFood += rate * 0.5;
          untransportedBread += untransportedRate;
          untransportedFood += untransportedRate * 0.5;
          break;
        case BuildingType.scribeWorkshop:
          netPlank += rate;
          untransportedPlank += untransportedRate;
          break;
        case BuildingType.geothermalBath:
        case BuildingType.steamVent:
          netStone += rate;
          untransportedStone += untransportedRate;
          break;
        case BuildingType.obsidianForge:
        case BuildingType.permafrostDig:
          netStone += rate * 0.5;
          netIron += rate * 0.5;
          untransportedStone += untransportedRate * 0.5;
          untransportedIron += untransportedRate * 0.5;
          break;
        case BuildingType.celestialAnvil:
          netStone += rate * 0.5;
          netIron += rate * 0.5;
          untransportedStone += untransportedRate * 0.5;
          untransportedIron += untransportedRate * 0.5;
          break;
        case BuildingType.astrolabe:
        case BuildingType.ancestralTotem:
        case BuildingType.prismaticResonator:
          netFood += rate * 0.4;
          netWood += rate * 0.4;
          netStone += rate * 0.4;
          untransportedFood += untransportedRate * 0.4;
          untransportedWood += untransportedRate * 0.4;
          untransportedStone += untransportedRate * 0.4;
          break;
        case BuildingType.kumisYurt:
          netKumis += rate;
          untransportedKumis += untransportedRate;
          break;
        case BuildingType.feltTentWorkshop:
          netFelt += rate;
          untransportedFelt += untransportedRate;
          break;
        case BuildingType.damascusForge:
          netDamascusSteel += rate;
          untransportedDamascusSteel += untransportedRate;
          break;
        case BuildingType.runicStele:
          netWisdom += rate;
          untransportedWisdom += untransportedRate;
          break;
        case BuildingType.granaryVault:
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
      wisdom: netWisdom,
      kumis: netKumis,
      felt: netFelt,
      damascusSteel: netDamascusSteel,
      untransportedFood: untransportedFood,
      untransportedWood: untransportedWood,
      untransportedStone: untransportedStone,
      untransportedIron: untransportedIron,
      untransportedFlour: untransportedFlour,
      untransportedPlank: untransportedPlank,
      untransportedBread: untransportedBread,
      untransportedFurniture: untransportedFurniture,
      untransportedFish: untransportedFish,
      untransportedWisdom: untransportedWisdom,
      untransportedKumis: untransportedKumis,
      untransportedFelt: untransportedFelt,
      untransportedDamascusSteel: untransportedDamascusSteel,
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

      // Komşuda fethedilmiş Kutlu Tapınak (Shrine) varsa +%50 taşıma ve bereket sinerjisi ver
      if (neighbor.hasShrine && neighbor.isOwned) {
        synergy += 0.50;
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

      if (neighbor.hasShrine && neighbor.isOwned) {
        labels.add('+50% Kutlu Tapınak Aurası & Taşıma Bonusu');
      }

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

  /// 9. Etik Reklam Günlük İzleme Limitleri (AGENTS.md Madde 14 & 15 Uyumlu)
  static int getMaxDailyWatches(AdRewardType type) {
    switch (type) {
      case AdRewardType.offlineProgressBoost:
        return 999999;
      case AdRewardType.marketQuotaReset:
        return 2;
      case AdRewardType.caravanBonus:
        return 3;
      case AdRewardType.celestialBlessing:
        return 2;
      case AdRewardType.migrationLegacy:
        return 1;
      case AdRewardType.frenzyBoost:
        return 999999;
    }
  }

  /// 10. Reklam Ödülü Azalan Verim Çarpanı (Soft Diminishing Returns)
  static double getAdRewardDiminishingReturn(int dailyWatches) {
    switch (dailyWatches) {
      case 0:
        return 1.0;
      case 1:
        return 0.8;
      case 2:
        return 0.6;
      default:
        return 0.4;
    }
  }

  /// 11. Gezgin Kervan Dinamik Reklam Ödül Paketi (Hoş Geldin & Dönüş İkramı)
  static Map<String, double> calculateCaravanAdBonus({
    required int castleLevel,
    required int crowns,
    required int dailyWatches,
  }) {
    final double mult = getGlobalMultiplier(castleLevel: castleLevel, crowns: crowns);
    final double dimReturn = getAdRewardDiminishingReturn(dailyWatches);
    final double baseAmount = (30.0 + castleLevel * 15.0) * mult * dimReturn;

    return {
      'wood': (baseAmount * 1.2).clamp(30.0, 1000.0),
      'food': (baseAmount * 1.5).clamp(30.0, 1200.0),
      'stone': (baseAmount * 0.8).clamp(15.0, 600.0),
      'iron': (baseAmount * 0.5).clamp(8.0, 300.0),
    };
  }

  /// 12. Çevrimdışı 2.0x Çift Kat Bereketli Kazanç Hesabı
  static OfflineGainsResult calculateOfflineAdBoostedGains(OfflineGainsResult original) {
    const double boost = 2.0;
    return OfflineGainsResult(
      seconds: original.seconds,
      food: original.food * boost,
      wood: original.wood * boost,
      flour: original.flour * boost,
      plank: original.plank * boost,
      bread: original.bread * boost,
      furniture: original.furniture * boost,
      stone: original.stone * boost,
      iron: original.iron * boost,
      fish: original.fish * boost,
      wisdom: original.wisdom * boost,
      kumis: original.kumis * boost,
      felt: original.felt * boost,
      damascusSteel: original.damascusSteel * boost,
    );
  }

  /// 13. Orhun Bitig Taşları Saniyelik Bilgelik (Lore) Üretimi
  static double calculateWisdomProductionRate({
    required Map<HexAxial, HexTileModel> tiles,
    required int castleLevel,
    List<String> unlockedLoreIds = const [],
  }) {
    double totalRate = 0.0;
    for (final tile in tiles.values) {
      if (tile.isOwned && tile.building?.type == BuildingType.runicStele) {
        totalRate += tile.building!.currentProductionRate;
      }
    }
    if (totalRate <= 0.0) return 0.0;

    final double castleMult = 1.0 + (castleLevel - 1) * 0.01;
    return totalRate * castleMult;
  }

  /// 14. Lojistik Kurgan Mahzenleri Bölgesel Taşıma ve Hasat Tampon Bonusu
  static double getGranaryVaultBufferBonus(HexAxial coord, dynamic tiles) {
    Iterable<HexTileModel> tileList;
    if (tiles is Map) {
      tileList = tiles.values.cast<HexTileModel>();
    } else if (tiles is Iterable<HexTileModel>) {
      tileList = tiles;
    } else {
      return 1.0;
    }

    for (final tile in tileList) {
      if (tile.isOwned && tile.building?.type == BuildingType.granaryVault) {
        final int dist = coord.distanceTo(tile.coord);
        if (dist <= 3) {
          return 1.50; // 3 Hex yarıçapında +%50 lojistik & toplama hız çarpanı
        }
      }
    }
    return 1.0;
  }

  /// 15. İleri Seviye Bozkır Zanaat Çıktı Oranları (Kımız, Keçe, Şam Çeliği)
  /// Kutsal Ambar Rezervi (%15 / 15 birim koruması): Temel kaynakların tamamen tükenmesini önler.
  static Map<String, double> calculateAdvancedCraftingYield({
    required BuildingType buildingType,
    required ResourcesModel resources,
    double globalMultiplier = 1.0,
    List<String> unlockedLoreIds = const [],
    double reserveFloor = 15.0,
  }) {
    switch (buildingType) {
      case BuildingType.kumisYurt:
        // Gıda -> Kımız dönüşümü (1.0 gıda -> 0.25 kımız), 15 Gıda taban rezervi korunur
        final double soilMultiplier = unlockedLoreIds.contains('lore_soil_2') ? 1.35 : 1.0;
        final bool canCraft = resources.food > (reserveFloor + 1.0);
        final double maxCraft = canCraft ? 0.25 * globalMultiplier * soilMultiplier : 0.0;
        return {
          'consumed_food': canCraft ? 1.0 : 0.0,
          'gained_kumis': maxCraft,
        };

      case BuildingType.feltTentWorkshop:
        // Odun + Gıda -> Keçe dönüşümü, 15 Odun ve 15 Gıda taban rezervi korunur
        final double weatherMultiplier = unlockedLoreIds.contains('lore_weather_2') ? 1.40 : 1.0;
        final bool canCraft = resources.wood > (reserveFloor + 0.5) && resources.food > (reserveFloor + 0.5);
        final double maxCraft = canCraft ? 0.22 * globalMultiplier * weatherMultiplier : 0.0;
        return {
          'consumed_wood': canCraft ? 0.5 : 0.0,
          'consumed_food': canCraft ? 0.5 : 0.0,
          'gained_felt': maxCraft,
        };

      case BuildingType.damascusForge:
        // Demir + Odun -> Şam Çeliği dönüşümü, 15 Demir ve 15 Odun taban rezervi korunur
        final double metalMultiplier = unlockedLoreIds.contains('lore_metal_2') ? 1.50 : 1.0;
        final bool canCraft = resources.iron > (reserveFloor + 0.5) && resources.wood > (reserveFloor + 0.5);
        final double maxCraft = canCraft ? 0.18 * globalMultiplier * metalMultiplier : 0.0;
        return {
          'consumed_iron': canCraft ? 0.5 : 0.0,
          'consumed_wood': canCraft ? 0.5 : 0.0,
          'gained_damascus_steel': maxCraft,
        };

      default:
        return const {};
    }
  }

  /// 16. Büyük Göç Coğrafyaları Özellikleri ve Biyom Çarpanları (Altay, İdil, Karakum)
  static Map<String, double> getMigrationRealmModifiers(String realmId) {
    switch (realmId.toLowerCase()) {
      case 'idil':
        // İdil-Yayık Nehir Havzası: Balık, Gıda, Un, Kımız bereketi
        return {
          'food_mult': 2.0,
          'fish_mult': 2.0,
          'flour_mult': 1.5,
          'kumis_mult': 1.5,
          'sea_cost_discount': 0.30,
        };
      case 'karakum':
        // Karakum & Tarım Havzası: Pazar, Kervan, Keçe, Taç bereketi
        return {
          'trade_order_speed': 2.0,
          'caravan_mult': 2.0,
          'felt_mult': 1.5,
          'crowns_mult': 2.0,
          'meadow_cost_discount': 0.25,
        };
      case 'altay':
      default:
        // Altay Göksel Platoları: Taş, Demir, Şam Çeliği, Kurgan bereketi
        return {
          'stone_mult': 2.0,
          'iron_mult': 2.0,
          'damascus_steel_mult': 2.0,
          'mountain_cost_discount': 0.30,
        };
    }
  }

  /// 17. İpek Yolu Başlangıç Kervan Siparişleri (Han Buyrukları) Üretici
  static List<TradeOrderModel> generateInitialTradeOrders() {
    return [
      const TradeOrderModel(
        id: 'order_byzantine_1',
        title: 'Bizans Sarayı Kereste Buyruğu',
        requesterName: 'Konstantinopolis Elçisi',
        requiredResources: {
          'wood': 80.0,
          'bread': 40.0,
        },
        rewardCrowns: 8,
        rewardSpeedMultiplier: 1.35,
        buffDurationSeconds: 600,
        createdAt: '2026-08-26',
      ),
      const TradeOrderModel(
        id: 'order_sogdian_1',
        title: 'Soğd Kervanı Demir & Un Takası',
        requesterName: 'Semerkant Başkâtibi',
        requiredResources: {
          'stone': 60.0,
          'flour': 50.0,
          'iron': 20.0,
        },
        rewardCrowns: 14,
        rewardSpeedMultiplier: 1.50,
        buffDurationSeconds: 900,
        createdAt: '2026-08-26',
      ),
      const TradeOrderModel(
        id: 'order_persian_1',
        title: 'Sasani Hanı Kımız & Keçe Seferi',
        requesterName: 'İsfahan Saray Kethüdası',
        requiredResources: {
          'furniture': 40.0,
          'bread': 50.0,
          'food': 100.0,
        },
        rewardCrowns: 20,
        rewardSpeedMultiplier: 1.75,
        buffDurationSeconds: 1200,
        createdAt: '2026-08-26',
      ),
    ];
  }

  /// 18. Kompakt Sayı Biçimlendirme Köprüsü (1000 -> 1K, 1000000 -> 1M)
  static String formatCompactNumber(
    num value, {
    int decimals = 1,
    bool explicitSign = false,
  }) {
    return NumberFormatter.format(
      value,
      decimals: decimals,
      explicitSign: explicitSign,
    );
  }

  /// 19. Görev İlerleme ve Ödül Ölçekleme Çarpanı
  static int calculateQuestScaledReward({
    required int baseReward,
    required int questIndex,
    int castleLevel = 1,
  }) {
    final double scalingFactor = 1.0 + (questIndex * 0.15) + (math.max(0, castleLevel - 1) * 0.10);
    return (baseReward * scalingFactor).round();
  }
}

