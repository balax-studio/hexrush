import 'dart:math' as math;
import '../../core/hex/hex_coordinates.dart';
import '../models/building_model.dart';
import '../models/combat_model.dart';
import '../models/game_state_model.dart';
import '../models/hex_tile_model.dart';
import 'economy_calculator.dart';

class TowerCombatStats {
  final int level;
  final int range;
  final double damage;
  final double cooldownSeconds;
  final double projectileSpeed;
  final bool isAoE;

  const TowerCombatStats({
    required this.level,
    this.range = 3,
    required this.damage,
    required this.cooldownSeconds,
    this.projectileSpeed = 4.0,
    this.isAoE = false,
  });

  double get dps => damage / math.max(0.1, cooldownSeconds);
}

class WaveVictoryReward {
  final int crowns;
  final int tamgas;
  final Map<String, double> resources;

  const WaveVictoryReward({
    this.crowns = 0,
    this.tamgas = 0,
    this.resources = const {},
  });
}

/// HexRush Savaş, Dalga, Kule ve Tahribat Motoru (Pure Dart Engine)
class CombatCalculator {
  /// Şato / Kağan Otağı Maksimum Can Puanı
  static double calculateCastleMaxHp(int castleLevel) {
    if (castleLevel <= 1) return 150.0;
    return 150.0 + (castleLevel - 1) * 120.0;
  }

  /// Kule Seviyesine Göre Savaş İstatistikleri (Menzil R=3 Sabit)
  static TowerCombatStats calculateTowerStats(int towerLevel) {
    final int lvl = math.max(1, towerLevel);
    final double damage = 18.0 * (1.0 + (lvl - 1) * 0.45);
    final double cooldown = math.max(0.35, 1.25 - (lvl - 1) * 0.08);
    final bool isAoE = lvl >= 5; // Seviye 5+ alevli/mancınık alan hasarı kazanır
    return TowerCombatStats(
      level: lvl,
      range: 3,
      damage: damage,
      cooldownSeconds: cooldown,
      projectileSpeed: 4.5,
      isAoE: isAoE,
    );
  }

  /// Kule Geliştirme Maliyeti (Tier 1-4 Gerçek Oyun Zinciri Entegrasyonu)
  static Map<String, double> calculateTowerUpgradeCost(int currentLevel) {
    if (currentLevel <= 0) {
      return {'wood': 25.0}; // Seviye 1 İnşa
    }

    switch (currentLevel) {
      case 1: // 1 -> 2 (Tier 1: Odun & Taş)
        return {'wood': 40.0, 'stone': 20.0};
      case 2: // 2 -> 3 (Tier 1: Odun & Taş)
        return {'wood': 80.0, 'stone': 50.0};
      case 3: // 3 -> 4 (Tier 2: Kereste & Taş & Ekmek Kumanyası)
        return {'plank': 35.0, 'stone': 80.0, 'bread': 15.0};
      case 4: // 4 -> 5 (Tier 2: Kereste & Taş & Ekmek)
        return {'plank': 80.0, 'stone': 150.0, 'bread': 35.0};
      case 5: // 5 -> 6 (Tier 3: Kereste & Demir & Keçe Zırh)
        return {'plank': 120.0, 'iron': 40.0, 'felt': 20.0};
      case 6: // 6 -> 7 (Tier 3: Demir & Keçe & Kımız)
        return {'iron': 80.0, 'felt': 45.0, 'kumis': 25.0};
      case 7: // 7 -> 8 (Tier 3: Demir & Keçe & Kımız)
        return {'iron': 140.0, 'felt': 80.0, 'kumis': 50.0};
      case 8: // 8 -> 9 (Tier 4: Şam Çeliği & Obsidyen & Bilgelik)
        return {'damascusSteel': 25.0, 'obsidian': 20.0, 'wisdom': 15.0};
      default: // 9+ (Tier 4: Katlanan Efsanevi Kaynaklar)
        final int mult = currentLevel - 8;
        return {
          'damascusSteel': 35.0 * mult,
          'obsidian': 30.0 * mult,
          'wisdom': 25.0 * mult,
        };
    }
  }

  /// Sur İnşa ve Yükseltme Maliyeti
  static Map<String, double> calculateWallCost(WallTier tier) {
    switch (tier) {
      case WallTier.woodenPalisade:
        return {'wood': 25.0};
      case WallTier.stoneRampart:
        return {'stone': 45.0, 'wood': 20.0};
      case WallTier.ironFortification:
        return {'iron': 35.0, 'stone': 65.0, 'plank': 25.0};
    }
  }

  /// Sur Onarım Maliyeti (Kalan can oranına göre dinamik)
  static Map<String, double> calculateWallRepairCost(CombatWallModel wall) {
    final double missingRatio = wall.isBreached
        ? 1.0
        : (1.0 - wall.hpPercentage).clamp(0.1, 1.0);
    final baseCost = calculateWallCost(wall.tier);
    final Map<String, double> repairCost = {};
    baseCost.forEach((res, amount) {
      repairCost[res] = math.max(1.0, (amount * 0.6 * missingRatio).roundToDouble());
    });
    return repairCost;
  }

  /// Hasarlı Karo Onarım Maliyeti (Mevcut bina yükseltme bedelinin %50'si)
  static Map<String, double> calculateTileRepairCost(HexTileModel tile) {
    if (!tile.isDamaged) return {};
    if (tile.building == null) {
      return {'wood': 10.0, 'stone': 5.0};
    }

    final BuildingModel b = tile.building!;
    final double costVal = b.upgradeCost * 0.5;
    final String resKey = (b.type == BuildingType.lumberjack || b.type == BuildingType.sawmill)
        ? 'wood'
        : (b.type == BuildingType.quarry || b.type == BuildingType.mine)
            ? 'stone'
            : 'food';
    return {resKey: math.max(5.0, costVal.roundToDouble())};
  }

  /// Şato Onarım Maliyeti (Hasar aldığında)
  static Map<String, double> calculateCastleRepairCost({
    required int castleLevel,
    required double castleCurrentHp,
    required double castleMaxHp,
  }) {
    final double missingHp = math.max(0.0, castleMaxHp - castleCurrentHp);
    if (missingHp <= 0.0) return {};
    final double missingRatio = (missingHp / castleMaxHp).clamp(0.05, 1.0);

    return {
      'wood': math.max(10.0, (30.0 * castleLevel * missingRatio).roundToDouble()),
      'stone': math.max(10.0, (25.0 * castleLevel * missingRatio).roundToDouble()),
    };
  }

  /// Keşfedilmiş en uzak sınırlardaki karolardan rastgele 2-4 adet akın başlangıç noktası seçer
  static List<HexAxial> selectFarthestSpawnPoints({
    required Map<HexAxial, HexTileModel> tiles,
    required HexAxial castleCoord,
    int maxSpawns = 3,
    int seed = 42,
  }) {
    // Sis olmayan, açık ve keşfedilmiş karolar
    final discoveredTiles = tiles.values
        .where((t) => !t.isFog && t.coord != castleCoord)
        .toList();

    if (discoveredTiles.isEmpty) {
      return [const HexAxial(1, 0)];
    }

    // Şatoya olan mesafelerine göre maksimum mesafeyi bul
    int maxDist = 0;
    for (final t in discoveredTiles) {
      final int d = t.coord.distanceTo(castleCoord);
      if (d > maxDist) maxDist = d;
    }

    // En uzak hizada yer alan sınır karolarını filtrele (maxDist veya maxDist - 1)
    final candidates = discoveredTiles
        .where((t) => t.coord.distanceTo(castleCoord) >= math.max(1, maxDist - 1))
        .map((t) => t.coord)
        .toList();

    if (candidates.isEmpty) {
      return [discoveredTiles.first.coord];
    }

    final math.Random random = math.Random(seed);
    candidates.shuffle(random);

    final int takeCount = math.min(maxSpawns, candidates.length);
    return candidates.take(takeCount).toList();
  }

  /// Seviye N Dalga Düşman Üretimi (Düşman sayısı çağrı seviyesiyle artar)
  static List<CombatEnemyInstance> generateWave({
    required int waveTier,
    required List<HexAxial> boundaryCoords,
    required HexAxial castleCoord,
    required Map<HexAxial, HexTileModel> tiles,
  }) {
    if (boundaryCoords.isEmpty) return [];

    final int tier = math.max(1, waveTier);
    // Çağrı seviyesiyle artan düşman sayısı (Sv 1 -> 7, Sv 2 -> 10, Sv 5 -> 19, Sv 10 -> 34)
    final int enemyCount = 4 + tier * 3;
    final List<CombatEnemyInstance> enemies = [];

    final math.Random random = math.Random(tier * 7919 + boundaryCoords.length * 37);

    for (int i = 0; i < enemyCount; i++) {
      final HexAxial spawnCoord = boundaryCoords[i % boundaryCoords.length];

      // En kısa yolu BFS ile hesapla (Düşmanın amacı şatoya ilerlemektir)
      final List<HexAxial> path = calculatePathToCastle(
        start: spawnCoord,
        target: castleCoord,
        tiles: tiles,
      );

      CombatEnemyType type;
      double baseHp;
      double speed;
      double dps;

      if (tier <= 2) {
        if (random.nextDouble() < 0.6) {
          type = CombatEnemyType.steppeRaider;
          baseHp = 45.0;
          speed = 0.9;
          dps = 8.0;
        } else {
          type = CombatEnemyType.shadowWolf;
          baseHp = 25.0;
          speed = 1.4;
          dps = 6.0;
        }
      } else if (tier <= 5) {
        final double roll = random.nextDouble();
        if (roll < 0.4) {
          type = CombatEnemyType.steppeRaider;
          baseHp = 60.0;
          speed = 0.95;
          dps = 12.0;
        } else if (roll < 0.7) {
          type = CombatEnemyType.shadowWolf;
          baseHp = 35.0;
          speed = 1.5;
          dps = 10.0;
        } else {
          type = CombatEnemyType.siegeRam;
          baseHp = 130.0;
          speed = 0.55;
          dps = 24.0;
        }
      } else {
        final double roll = random.nextDouble();
        if (roll < 0.3) {
          type = CombatEnemyType.steppeRaider;
          baseHp = 80.0;
          speed = 1.0;
          dps = 18.0;
        } else if (roll < 0.55) {
          type = CombatEnemyType.shadowWolf;
          baseHp = 50.0;
          speed = 1.6;
          dps = 14.0;
        } else if (roll < 0.8) {
          type = CombatEnemyType.siegeRam;
          baseHp = 180.0;
          speed = 0.6;
          dps = 32.0;
        } else {
          type = CombatEnemyType.erlikChampion;
          baseHp = 300.0;
          speed = 0.75;
          dps = 45.0;
        }
      }

      // Seviye çarpanı
      final double hpMult = 1.0 + (tier - 1) * 0.35;
      final double dpsMult = 1.0 + (tier - 1) * 0.25;

      enemies.add(
        CombatEnemyInstance(
          id: 'enemy_${tier}_$i',
          type: type,
          maxHp: baseHp * hpMult,
          currentHp: baseHp * hpMult,
          speed: speed,
          currentCoord: spawnCoord,
          path: path,
          pathIndex: 0,
          damagePerSecond: dps * dpsMult,
        ),
      );
    }

    return enemies;
  }

  /// BFS ile Sınır Karosundan Şatoya En Kısa Hex Yolu
  static List<HexAxial> calculatePathToCastle({
    required HexAxial start,
    required HexAxial target,
    required Map<HexAxial, HexTileModel> tiles,
  }) {
    if (start == target) return [start];

    final Set<HexAxial> visited = {start};
    final List<List<HexAxial>> queue = [
      [start]
    ];

    while (queue.isNotEmpty) {
      final List<HexAxial> currentPath = queue.removeAt(0);
      final HexAxial current = currentPath.last;

      if (current == target) {
        return currentPath;
      }

      // 6 komşu yönü tara
      for (final HexAxial neighbor in current.neighbors) {
        if (tiles.containsKey(neighbor) && !visited.contains(neighbor)) {
          visited.add(neighbor);
          final List<HexAxial> newPath = List.from(currentPath)..add(neighbor);
          if (neighbor == target) {
            return newPath;
          }
          queue.add(newPath);
        }
      }
    }

    // Doğrudan hedef çizgisi (yedek): mesafe azaltan adımlarla Şatoya yaklaş
    final List<HexAxial> fallbackPath = [start];
    HexAxial curr = start;
    while (curr != target) {
      HexAxial bestNeighbor = curr;
      int minD = curr.distanceTo(target);
      for (final n in curr.neighbors) {
        final int d = n.distanceTo(target);
        if (d < minD) {
          minD = d;
          bestNeighbor = n;
        }
      }
      if (bestNeighbor == curr) break;
      curr = bestNeighbor;
      fallbackPath.add(curr);
    }
    if (fallbackPath.last != target) fallbackPath.add(target);
    return fallbackPath;
  }

  /// Zafer Ödülü Hesaplama (Seviye N Tamamlandığında)
  static WaveVictoryReward calculateWaveVictoryReward(int waveTier) {
    final int tier = math.max(1, waveTier);
    final int crowns = 3 + tier * 2;
    final int tamgas = tier >= 5 ? (tier ~/ 5) : 0;

    final Map<String, double> resources = {
      'wood': (25.0 * tier),
      'stone': (15.0 * tier),
      'food': (20.0 * tier),
    };

    if (tier >= 3) {
      resources['iron'] = 10.0 * (tier - 2);
    }
    if (tier >= 6) {
      resources['felt'] = 8.0 * (tier - 5);
      resources['kumis'] = 6.0 * (tier - 5);
    }
    if (tier >= 9) {
      resources['damascusSteel'] = 5.0 * (tier - 8);
      resources['obsidian'] = 5.0 * (tier - 8);
    }

    return WaveVictoryReward(
      crowns: crowns,
      tamgas: tamgas,
      resources: resources,
    );
  }
}
