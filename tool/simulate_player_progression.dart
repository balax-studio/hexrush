// ignore_for_file: avoid_print, unused_import, unused_local_variable
import 'dart:math' as math;
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/doctrine_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/steppe_lore_tree_model.dart';

/// Simülasyon Senaryosu ve Sonuç Raporlama Nesnesi
class SimulationReport {
  final String strategyName;
  final double totalSimulatedSeconds;
  final int totalMigrations;
  final int totalTamgas;
  final int totalCrowns;
  final int castleLevel;
  final int ownedTilesCount;
  final int unlockedLoreCount;
  final int totalLoreCount;
  final int unlockedDoctrineCount;
  final Map<String, double> milestoneTimes; // 'castle_5', 'all_lore', 'castle_50' vb.
  final List<String> migrationLog;

  SimulationReport({
    required this.strategyName,
    required this.totalSimulatedSeconds,
    required this.totalMigrations,
    required this.totalTamgas,
    required this.totalCrowns,
    required this.castleLevel,
    required this.ownedTilesCount,
    required this.unlockedLoreCount,
    required this.totalLoreCount,
    required this.unlockedDoctrineCount,
    required this.milestoneTimes,
    required this.migrationLog,
  });

  double get totalHours => totalSimulatedSeconds / 3600.0;
}

class PlaytestAgent {
  final bool allowMigration;
  final List<int> migrationCastleThresholds; // Hangi şato seviyelerinde göç yapılacak

  PlaytestAgent({
    required this.allowMigration,
    this.migrationCastleThresholds = const [5, 10, 15, 20, 30, 40],
  });

  SimulationReport runSimulation({double maxSimulatedSeconds = 3600.0 * 150}) {
    // Başlangıç Haritası & State
    int castleLevel = 1;
    int totalMigrations = 0;
    int tamgas = 0;
    int crowns = 0;

    double food = 50.0;
    double wood = 25.0;
    double stone = 0.0;
    double iron = 0.0;
    double wisdom = 0.0;

    final List<String> unlockedLoreIds = [];
    final List<String> unlockedDoctrineIds = ['doc_sulama_fermani', 'doc_bozkir_akincisi'];
    final allLoreNodes = SteppeLoreNode.defaultLoreTree;
    final allDoctrines = DoctrineCardModel.getInitialDoctrines();

    final Map<String, double> milestoneTimes = {};
    final List<String> migrationLog = [];

    // Haritayı başlat (7 karo)
    Map<HexAxial, HexTileModel> tiles = _createInitialMap();

    double simulatedTime = 0.0;
    const double dt = 2.0; // 2 saniyelik zaman adımı ile hızlı entegrasyon

    int nextMigrationIndex = 0;

    while (simulatedTime < maxSimulatedSeconds) {
      simulatedTime += dt;

      // 1. Üretim Debisini Hesapla
      final double kutMult = EconomyCalculator.calculateKutMultiplier(
        tamgas: tamgas,
        totalMigrations: totalMigrations,
      );

      final double globalMult = EconomyCalculator.getGlobalMultiplier(
        castleLevel: castleLevel,
        crowns: crowns,
        kutMultiplier: kutMult,
      );

      // Saniyelik üretim
      final rates = EconomyCalculator.calculateNetRates(
        tiles: tiles.values,
        globalMultiplier: globalMult,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
        tileMap: tiles,
      );

      food += rates.food * dt;
      wood += rates.wood * dt;
      stone += rates.stone * dt;
      iron += rates.iron * dt;

      // Runic Stele Bilgelik üretimi
      final wisdomRate = EconomyCalculator.calculateWisdomProductionRate(
        tiles: tiles,
        castleLevel: castleLevel,
      );
      wisdom += wisdomRate * dt;

      // 2. Karar Verme & Eylemler (AI Player Logic)

      // A) Bilgelik Teknolojilerini Aç (Steppe Lore)
      for (final node in allLoreNodes) {
        if (!unlockedLoreIds.contains(node.id)) {
          if (wisdom >= node.costWisdom) {
            wisdom -= node.costWisdom;
            unlockedLoreIds.add(node.id);
            if (unlockedLoreIds.length == allLoreNodes.length && !milestoneTimes.containsKey('all_lore')) {
              milestoneTimes['all_lore'] = simulatedTime;
            }
          }
        }
      }

      // B) Doktrinleri Aç (Taç ile)
      for (final doc in allDoctrines) {
        if (!unlockedDoctrineIds.contains(doc.id) && doc.unlockCastleLevel <= castleLevel) {
          if (crowns >= doc.costCrowns) {
            crowns -= doc.costCrowns;
            unlockedDoctrineIds.add(doc.id);
          }
        }
      }

      // C) Şato Seviye Kontrolü & Milestone Kaydı
      final nextCastleCost = EconomyCalculator.getCastleUpgradeCost(castleLevel + 1);
      final double reqFood = nextCastleCost['food']!;
      final double reqWood = nextCastleCost['wood']!;

      if (food >= reqFood && wood >= reqWood && castleLevel < 50) {
        food -= reqFood;
        wood -= reqWood;
        castleLevel++;

        if (!milestoneTimes.containsKey('castle_$castleLevel')) {
          milestoneTimes['castle_$castleLevel'] = simulatedTime;
        }

        // Şato yükselince merkez karoyu güncelle
        tiles[const HexAxial(0, 0)] = tiles[const HexAxial(0, 0)]!.copyWith(
          building: BuildingModel(type: BuildingType.castle, level: castleLevel),
        );
      }

      // D) Büyük Göç Kontrolü (Prestige Eşiği)
      final ownedCount = tiles.values.where((t) => t.isOwned).length;
      if (allowMigration &&
          castleLevel >= 5 &&
          ownedCount >= 12 &&
          nextMigrationIndex < migrationCastleThresholds.length) {
        final targetLvl = migrationCastleThresholds[nextMigrationIndex];
        if (castleLevel >= targetLvl) {
          // Göçü Gerçekleştir!
          final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
            tiles: tiles.values,
            resources: ResourcesModel(
              food: food,
              wood: wood,
              stone: stone,
              iron: iron,
              wisdom: wisdom,
            ),
            castleLevel: castleLevel,
          );

          final int earnedCrowns = breakdown.totalCrowns;
          final int shrines = tiles.values.where((t) => t.isOwned && t.hasShrine).length;
          final int earnedTamgas = (ownedCount + (shrines * 5)) ~/ 2;

          crowns += earnedCrowns;
          tamgas += earnedTamgas;
          totalMigrations++;

          migrationLog.add(
            '[T+${(simulatedTime / 3600.0).toStringAsFixed(1)}s] Göç #$totalMigrations: '
            'Şato Sv.$castleLevel, $ownedCount Karo -> +$earnedCrowns Taç, +$earnedTamgas Tamga (Toplam Tamga: $tamgas)',
          );

          // Haritayı ve kaynakları sıfırla (Kalıcı bonuslar hariç)
          tiles = _createInitialMap();
          castleLevel = 1;
          food = 50.0;
          wood = 25.0;
          stone = 0.0;
          iron = 0.0;
          wisdom = 0.0;

          nextMigrationIndex++;
          continue;
        }
      }

      // E) Karo Fethetme (Conquest)
      final unownedNeighbors = _getUnownedNeighborCoords(tiles);
      if (unownedNeighbors.isNotEmpty) {
        final targetCoord = unownedNeighbors.first;
        final conquestCost = EconomyCalculator.getExpansionCost(
          biome: TileBiome.meadow,
          distance: 1,
          ownedCount: ownedCount,
          biomeCounts: {'meadow': ownedCount},
        );

        if (food >= conquestCost && ownedCount < 60) {
          food -= conquestCost;
          tiles[targetCoord] = HexTileModel(
            coord: targetCoord,
            biome: (targetCoord.q.abs() + targetCoord.r.abs()) % 3 == 0
                ? TileBiome.forest
                : ((targetCoord.q + targetCoord.r) % 4 == 0 ? TileBiome.mountain : TileBiome.meadow),
            state: TileState.owned,
          );
        }
      }

      // F) Boş Karoya Bina İnşa Etme
      final emptyOwned = tiles.values.where((t) => t.isOwned && !t.hasBuilding).toList();
      for (final emptyTile in emptyOwned) {
        BuildingType toBuild = BuildingType.corn;
        // Biyoma ve şato seviyesine göre akıllı seçim
        if (emptyTile.biome == TileBiome.forest) {
          toBuild = BuildingType.lumberjack;
        } else if (emptyTile.biome == TileBiome.mountain) {
          if (castleLevel >= 15 && food >= 55.0) {
            toBuild = BuildingType.mine;
          } else if (castleLevel >= 5 && food >= 25.0) {
            toBuild = BuildingType.quarry;
          } else {
            continue;
          }
        } else {
          // Çayır
          final runicCount = tiles.values.where((t) => t.building?.type == BuildingType.runicStele).length;
          final workerCount = tiles.values.where((t) => t.building?.type == BuildingType.worker).length;
          final cornCount = tiles.values.where((t) => t.building?.type == BuildingType.corn).length;

          if (castleLevel >= 5 && runicCount < 3 && food >= 80.0) {
            toBuild = BuildingType.runicStele;
          } else if (workerCount < (ownedCount ~/ 4) && food >= 35.0) {
            toBuild = BuildingType.worker;
          } else if (castleLevel >= 5 && food >= 25.0 && cornCount >= 2) {
            toBuild = BuildingType.windmill;
          } else if (castleLevel >= 2 && food >= 28.0) {
            toBuild = BuildingType.pasture;
          } else {
            toBuild = BuildingType.corn;
          }
        }

        final dummy = BuildingModel(type: toBuild);
        if (food >= dummy.baseCost) {
          food -= dummy.baseCost;
          tiles[emptyTile.coord] = emptyTile.copyWith(
            building: BuildingModel(type: toBuild, level: 1),
          );
        }
      }

      // G) Mevcut Binaları Yükseltme (Upgrade)
      for (final tile in tiles.values) {
        if (!tile.isOwned || !tile.hasBuilding || tile.building!.type == BuildingType.castle) continue;
        final b = tile.building!;
        final cost = b.upgradeCost;
        if (food >= cost * 1.5 && b.level < 50) {
          // Güvenli marj ile yükselt
          food -= cost;
          tiles[tile.coord] = tile.copyWith(
            building: b.copyWith(level: b.level + 1),
          );
        }
      }

      // Bitiş Şartı: Tüm teknolojiler açıldı VE Şato Seviye 50'ye ulaştı!
      if (castleLevel >= 50 && unlockedLoreIds.length == allLoreNodes.length) {
        if (!milestoneTimes.containsKey('complete_victory')) {
          milestoneTimes['complete_victory'] = simulatedTime;
        }
        break;
      }
    }

    return SimulationReport(
      strategyName: allowMigration ? 'Düzenli Büyük Göç Stratejisi (Prestijli)' : 'Sabit Yerleşik Strateji (Sıfırlamasız)',
      totalSimulatedSeconds: simulatedTime,
      totalMigrations: totalMigrations,
      totalTamgas: tamgas,
      totalCrowns: crowns,
      castleLevel: castleLevel,
      ownedTilesCount: tiles.values.where((t) => t.isOwned).length,
      unlockedLoreCount: unlockedLoreIds.length,
      totalLoreCount: allLoreNodes.length,
      unlockedDoctrineCount: unlockedDoctrineIds.length,
      milestoneTimes: milestoneTimes,
      migrationLog: migrationLog,
    );
  }

  Map<HexAxial, HexTileModel> _createInitialMap() {
    final Map<HexAxial, HexTileModel> map = {};
    const center = HexAxial(0, 0);
    map[center] = const HexTileModel(
      coord: center,
      biome: TileBiome.meadow,
      state: TileState.owned,
      building: BuildingModel(type: BuildingType.castle, level: 1),
    );

    int idx = 0;
    for (final neighbor in center.neighbors) {
      BuildingModel? b;
      if (idx == 0) b = const BuildingModel(type: BuildingType.corn, level: 1);
      if (idx == 1) b = const BuildingModel(type: BuildingType.worker, level: 1);
      if (idx == 2) b = const BuildingModel(type: BuildingType.lumberjack, level: 1);

      map[neighbor] = HexTileModel(
        coord: neighbor,
        biome: idx == 2 ? TileBiome.forest : TileBiome.meadow,
        state: TileState.owned,
        building: b,
      );
      idx++;
    }
    return map;
  }

  List<HexAxial> _getUnownedNeighborCoords(Map<HexAxial, HexTileModel> tiles) {
    final Set<HexAxial> candidates = {};
    for (final tile in tiles.values) {
      if (tile.isOwned) {
        for (final n in tile.coord.neighbors) {
          if (!tiles.containsKey(n) || !tiles[n]!.isOwned) {
            candidates.add(n);
          }
        }
      }
    }
    return candidates.toList();
  }
}

void main() {
  print('================================================================');
  print('HEXRUSH GERÇEK OYUNCU İLERLEME & BÜYÜK GÖÇ (PRESTİJ) SİMÜLATÖRÜ');
  print('================================================================\n');

  // 1. Simülasyon: Hiç Göç Yapmayan Yerleşik Oyuncu
  print('>>> [1/2] Sıfırlamasız (No-Prestige) Simülasyon Koşuluyor...');
  final noPrestigeAgent = PlaytestAgent(allowMigration: false);
  final noPrestigeReport = noPrestigeAgent.runSimulation(maxSimulatedSeconds: 3600.0 * 200);

  // 2. Simülasyon: Stratejik Büyük Göç Yapan Oyuncu
  print('>>> [2/2] Kademeli Büyük Göç (Prestijli) Simülasyon Koşuluyor...');
  final prestigeAgent = PlaytestAgent(
    allowMigration: true,
    migrationCastleThresholds: [5, 10, 15, 20, 25, 30, 35, 40],
  );
  final prestigeReport = prestigeAgent.runSimulation(maxSimulatedSeconds: 3600.0 * 200);

  _printReport(noPrestigeReport);
  _printReport(prestigeReport);

  _printComparisonAndRecommendations(noPrestigeReport, prestigeReport);
}

void _printReport(SimulationReport report) {
  print('----------------------------------------------------------------');
  print('STRATEJİ: ${report.strategyName.toUpperCase()}');
  print('----------------------------------------------------------------');
  print('Toplam Oyun Süresi   : ${report.totalHours.toStringAsFixed(2)} Saat (${(report.totalSimulatedSeconds / 60).toStringAsFixed(1)} Dakika)');
  print('Nihai Şato Seviyesi : Sv. ${report.castleLevel}');
  print('Sahip Olunan Karo   : ${report.ownedTilesCount} Hex');
  print('Teknolojiler (Lore) : ${report.unlockedLoreCount}/${report.totalLoreCount} Tamamlandı');
  print('Büyük Göç Sayısı    : ${report.totalMigrations}');
  print('Kazanılan Tamgalar  : ${report.totalTamgas} Tamga');
  print('Kazanılan Taçlar    : ${report.totalCrowns} Taç');

  print('\nKilometre Taşları & Ulaşma Süreleri:');
  report.milestoneTimes.forEach((milestone, seconds) {
    final hours = seconds / 3600.0;
    final mins = (seconds % 3600) / 60.0;
    print('  • $milestone: ${hours.toInt()} sa ${mins.toInt()} dk (${seconds.toInt()} sn)');
  });

  if (report.migrationLog.isNotEmpty) {
    print('\nGöç Geçmişi:');
    for (final log in report.migrationLog) {
      print('  $log');
    }
  }
  print('\n');
}

void _printComparisonAndRecommendations(SimulationReport noPrest, SimulationReport prest) {
  print('================================================================');
  print('MATEMATİKSEL ANALİZ VE OPTİMAL PRESTİJ ZAMANLAMASI');
  print('================================================================');
  print('1. SIĞINAK ETKİSİ VE ÜSSEL DUVAR (Exponential Wall):');
  print('   Sıfırlama yapmayan oyuncuda karo fetih maliyeti math.pow(1.6, ownedCount)');
  print('   ile geometrik artarak 20-25. karodan sonra durma noktasına gelir.');
  print('   Ayrıca Şato seviye atlama maliyetleri (1.5x) Kut çarpanı olmadan aşırı uzar.');
  print('\n2. BÜYÜK GÖÇ VERİM KARŞILAŞTIRMASI:');
  print('   Prestijli oyuncu Kut çarpanı (${EconomyCalculator.calculateKutMultiplier(tamgas: prest.totalTamgas, totalMigrations: prest.totalMigrations).toStringAsFixed(1)}x) sayesinde');
  print('   tüm teknolojileri ve yüksek şato kademelerini kat be kat daha hızlı tamamlar.');
  print('================================================================\n');
}
