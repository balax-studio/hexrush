import 'dart:math' as math;
import '../../core/hex/hex_coordinates.dart';

enum CombatEnemyType {
  steppeRaider, // Bozkır Yağmacısı (Hızlı, dengeli)
  shadowWolf, // Gölge Kurt (Çok hızlı, düşük can)
  siegeRam, // Koçbaşı (Yavaş, yüksek can, surlara ekstra hasar)
  erlikChampion, // Erlik Savaşçısı (Ağır zırhlı boss)
}

extension CombatEnemyTypeExtension on CombatEnemyType {
  String get nameTr {
    switch (this) {
      case CombatEnemyType.steppeRaider:
        return 'Bozkır Yağmacısı';
      case CombatEnemyType.shadowWolf:
        return 'Gölge Kurt';
      case CombatEnemyType.siegeRam:
        return 'Bozkır Koçbaşı';
      case CombatEnemyType.erlikChampion:
        return 'Erlik Savaşçısı';
    }
  }

  String get nameEn {
    switch (this) {
      case CombatEnemyType.steppeRaider:
        return 'Steppe Raider';
      case CombatEnemyType.shadowWolf:
        return 'Shadow Wolf';
      case CombatEnemyType.siegeRam:
        return 'Siege Ram';
      case CombatEnemyType.erlikChampion:
        return 'Erlik Champion';
    }
  }
}

class CombatEnemyInstance {
  final String id;
  final CombatEnemyType type;
  final double maxHp;
  final double currentHp;
  final double speed; // Hex per second
  final HexAxial currentCoord;
  final List<HexAxial> path;
  final int pathIndex;
  final double damagePerSecond;
  final bool isAttackingWall;
  final bool isAttackingCastle;

  const CombatEnemyInstance({
    required this.id,
    required this.type,
    required this.maxHp,
    required this.currentHp,
    required this.speed,
    required this.currentCoord,
    required this.path,
    this.pathIndex = 0,
    required this.damagePerSecond,
    this.isAttackingWall = false,
    this.isAttackingCastle = false,
  });

  bool get isDead => currentHp <= 0.0;
  double get hpPercentage => (currentHp / math.max(1.0, maxHp)).clamp(0.0, 1.0);

  CombatEnemyInstance copyWith({
    String? id,
    CombatEnemyType? type,
    double? maxHp,
    double? currentHp,
    double? speed,
    HexAxial? currentCoord,
    List<HexAxial>? path,
    int? pathIndex,
    double? damagePerSecond,
    bool? isAttackingWall,
    bool? isAttackingCastle,
  }) {
    return CombatEnemyInstance(
      id: id ?? this.id,
      type: type ?? this.type,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      speed: speed ?? this.speed,
      currentCoord: currentCoord ?? this.currentCoord,
      path: path ?? this.path,
      pathIndex: pathIndex ?? this.pathIndex,
      damagePerSecond: damagePerSecond ?? this.damagePerSecond,
      isAttackingWall: isAttackingWall ?? this.isAttackingWall,
      isAttackingCastle: isAttackingCastle ?? this.isAttackingCastle,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'speed': speed,
        'currentCoord': currentCoord.toJson(),
        'path': path.map((c) => c.toJson()).toList(),
        'pathIndex': pathIndex,
        'damagePerSecond': damagePerSecond,
        'isAttackingWall': isAttackingWall,
        'isAttackingCastle': isAttackingCastle,
      };

  factory CombatEnemyInstance.fromJson(Map<String, dynamic> json) {
    return CombatEnemyInstance(
      id: json['id'] as String,
      type: CombatEnemyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CombatEnemyType.steppeRaider,
      ),
      maxHp: (json['maxHp'] as num).toDouble(),
      currentHp: (json['currentHp'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      currentCoord: HexAxial.fromJson(json['currentCoord'] as Map<String, dynamic>),
      path: (json['path'] as List<dynamic>?)
              ?.map((c) => HexAxial.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      pathIndex: (json['pathIndex'] as num?)?.toInt() ?? 0,
      damagePerSecond: (json['damagePerSecond'] as num).toDouble(),
      isAttackingWall: json['isAttackingWall'] as bool? ?? false,
      isAttackingCastle: json['isAttackingCastle'] as bool? ?? false,
    );
  }
}

class CombatProjectileInstance {
  final String id;
  final HexAxial sourceTowerCoord;
  final String targetEnemyId;
  final double damage;
  final double progress; // 0.0 to 1.0
  final bool isAoE;

  const CombatProjectileInstance({
    required this.id,
    required this.sourceTowerCoord,
    required this.targetEnemyId,
    required this.damage,
    this.progress = 0.0,
    this.isAoE = false,
  });

  CombatProjectileInstance copyWith({
    String? id,
    HexAxial? sourceTowerCoord,
    String? targetEnemyId,
    double? damage,
    double? progress,
    bool? isAoE,
  }) {
    return CombatProjectileInstance(
      id: id ?? this.id,
      sourceTowerCoord: sourceTowerCoord ?? this.sourceTowerCoord,
      targetEnemyId: targetEnemyId ?? this.targetEnemyId,
      damage: damage ?? this.damage,
      progress: progress ?? this.progress,
      isAoE: isAoE ?? this.isAoE,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceTowerCoord': sourceTowerCoord.toJson(),
        'targetEnemyId': targetEnemyId,
        'damage': damage,
        'progress': progress,
        'isAoE': isAoE,
      };

  factory CombatProjectileInstance.fromJson(Map<String, dynamic> json) {
    return CombatProjectileInstance(
      id: json['id'] as String,
      sourceTowerCoord: HexAxial.fromJson(json['sourceTowerCoord'] as Map<String, dynamic>),
      targetEnemyId: json['targetEnemyId'] as String,
      damage: (json['damage'] as num).toDouble(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isAoE: json['isAoE'] as bool? ?? false,
    );
  }
}

enum WallTier {
  woodenPalisade, // Ahşap Çit (Tier 1)
  stoneRampart, // Taş Sur (Tier 2)
  ironFortification, // Demir Tahkimat (Tier 3)
}

extension WallTierExtension on WallTier {
  String get titleTr {
    switch (this) {
      case WallTier.woodenPalisade:
        return 'Ahşap Çit';
      case WallTier.stoneRampart:
        return 'Taş Sur';
      case WallTier.ironFortification:
        return 'Demir Tahkimat';
    }
  }

  String get titleEn {
    switch (this) {
      case WallTier.woodenPalisade:
        return 'Wooden Palisade';
      case WallTier.stoneRampart:
        return 'Stone Rampart';
      case WallTier.ironFortification:
        return 'Iron Fortification';
    }
  }

  double get maxHp {
    switch (this) {
      case WallTier.woodenPalisade:
        return 150.0;
      case WallTier.stoneRampart:
        return 400.0;
      case WallTier.ironFortification:
        return 1000.0;
    }
  }

  double get passiveThornDps {
    switch (this) {
      case WallTier.woodenPalisade:
        return 5.0; // Kazık hasarı
      case WallTier.stoneRampart:
        return 12.0; // Mazgal & Hendek
      case WallTier.ironFortification:
        return 30.0; // Çelik Dikenli Barikat
    }
  }
}

class CombatWallModel {
  final WallTier tier;
  final double currentHp;
  final bool isBreached;

  const CombatWallModel({
    this.tier = WallTier.woodenPalisade,
    required this.currentHp,
    this.isBreached = false,
  });

  double get maxHp => tier.maxHp;
  double get hpPercentage => (currentHp / math.max(1.0, maxHp)).clamp(0.0, 1.0);
  bool get needsRepair => isBreached || currentHp < maxHp;

  CombatWallModel copyWith({
    WallTier? tier,
    double? currentHp,
    bool? isBreached,
  }) {
    return CombatWallModel(
      tier: tier ?? this.tier,
      currentHp: currentHp ?? this.currentHp,
      isBreached: isBreached ?? this.isBreached,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'currentHp': currentHp,
        'isBreached': isBreached,
      };

  factory CombatWallModel.fromJson(Map<String, dynamic> json) {
    return CombatWallModel(
      tier: WallTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => WallTier.woodenPalisade,
      ),
      currentHp: (json['currentHp'] as num).toDouble(),
      isBreached: json['isBreached'] as bool? ?? false,
    );
  }
}

class CombatState {
  final bool isActiveWave;
  final int currentWaveTier;
  final int maxCompletedWaveTier;
  final double castleMaxHp;
  final double castleCurrentHp;
  final List<CombatEnemyInstance> activeEnemies;
  final List<CombatProjectileInstance> activeProjectiles;
  final double waveElapsedTime;
  final Map<HexAxial, double> towerCooldowns;

  const CombatState({
    this.isActiveWave = false,
    this.currentWaveTier = 1,
    this.maxCompletedWaveTier = 0,
    this.castleMaxHp = 100.0,
    this.castleCurrentHp = 100.0,
    this.activeEnemies = const [],
    this.activeProjectiles = const [],
    this.waveElapsedTime = 0.0,
    this.towerCooldowns = const {},
  });

  double get castleHpPercentage => (castleCurrentHp / math.max(1.0, castleMaxHp)).clamp(0.0, 1.0);
  bool get isCastleDestroyed => castleCurrentHp <= 0.0;
  bool get isWaveCleared => isActiveWave && activeEnemies.isEmpty;
  int get remainingEnemyCount => activeEnemies.length;

  CombatState copyWith({
    bool? isActiveWave,
    int? currentWaveTier,
    int? maxCompletedWaveTier,
    double? castleMaxHp,
    double? castleCurrentHp,
    List<CombatEnemyInstance>? activeEnemies,
    List<CombatProjectileInstance>? activeProjectiles,
    double? waveElapsedTime,
    Map<HexAxial, double>? towerCooldowns,
  }) {
    return CombatState(
      isActiveWave: isActiveWave ?? this.isActiveWave,
      currentWaveTier: currentWaveTier ?? this.currentWaveTier,
      maxCompletedWaveTier: maxCompletedWaveTier ?? this.maxCompletedWaveTier,
      castleMaxHp: castleMaxHp ?? this.castleMaxHp,
      castleCurrentHp: castleCurrentHp ?? this.castleCurrentHp,
      activeEnemies: activeEnemies ?? this.activeEnemies,
      activeProjectiles: activeProjectiles ?? this.activeProjectiles,
      waveElapsedTime: waveElapsedTime ?? this.waveElapsedTime,
      towerCooldowns: towerCooldowns ?? this.towerCooldowns,
    );
  }

  Map<String, dynamic> toJson() => {
        'isActiveWave': isActiveWave,
        'currentWaveTier': currentWaveTier,
        'maxCompletedWaveTier': maxCompletedWaveTier,
        'castleMaxHp': castleMaxHp,
        'castleCurrentHp': castleCurrentHp,
        'activeEnemies': activeEnemies.map((e) => e.toJson()).toList(),
        'activeProjectiles': activeProjectiles.map((p) => p.toJson()).toList(),
        'waveElapsedTime': waveElapsedTime,
      };

  factory CombatState.fromJson(Map<String, dynamic> json) {
    return CombatState(
      isActiveWave: json['isActiveWave'] as bool? ?? false,
      currentWaveTier: (json['currentWaveTier'] as num?)?.toInt() ?? 1,
      maxCompletedWaveTier: (json['maxCompletedWaveTier'] as num?)?.toInt() ?? 0,
      castleMaxHp: (json['castleMaxHp'] as num?)?.toDouble() ?? 100.0,
      castleCurrentHp: (json['castleCurrentHp'] as num?)?.toDouble() ?? 100.0,
      activeEnemies: (json['activeEnemies'] as List<dynamic>?)
              ?.map((e) => CombatEnemyInstance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeProjectiles: (json['activeProjectiles'] as List<dynamic>?)
              ?.map((p) => CombatProjectileInstance.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      waveElapsedTime: (json['waveElapsedTime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
