import 'dart:math' as math;

enum BuildingType {
  castle,
  corn,
  windmill,
  bakery,
  lumberjack,
  sawmill,
  furniture,
  worker,
  watchtower,
  mine,
  bridge,
  fisherman,
  fishermanHut,
}

class BuildingModel {
// ... (omitting fields for brevity in replacementContent, but I should be careful)
// Actually I'll provide the full class content with changes to methods.

  final BuildingType type;
  final int level;
  final double accumulatedResource;
  final double totalGathered;

  const BuildingModel({
    required this.type,
    this.level = 1,
    this.accumulatedResource = 0.0,
    this.totalGathered = 0.0,
  });

  BuildingModel copyWith({
    BuildingType? type,
    int? level,
    double? accumulatedResource,
    double? totalGathered,
  }) {
    return BuildingModel(
      type: type ?? this.type,
      level: level ?? this.level,
      accumulatedResource: accumulatedResource ?? this.accumulatedResource,
      totalGathered: totalGathered ?? this.totalGathered,
    );
  }

  /// Binaların temel maliyet ve büyüme bilgileri
  double get baseCost {
    switch (type) {
      case BuildingType.castle:
        return 50.0;
      case BuildingType.corn:
        return 10.0;
      case BuildingType.lumberjack:
        return 15.0;
      case BuildingType.windmill:
        return 25.0;
      case BuildingType.sawmill:
        return 30.0;
      case BuildingType.bakery:
        return 50.0;
      case BuildingType.furniture:
        return 60.0;
      case BuildingType.worker:
        return 35.0;
      case BuildingType.watchtower:
        return 40.0;
      case BuildingType.mine:
        return 55.0;
      case BuildingType.bridge:
        return 20.0;
      case BuildingType.fisherman:
        return 30.0;
      case BuildingType.fishermanHut:
        return 45.0;
    }
  }

  double get costGrowthFactor => 1.15;

  /// Seviye yükseltme maliyeti
  double get upgradeCost => baseCost * math.pow(costGrowthFactor, level - 1);

  /// Temel üretim hızı (birim/saniye)
  double get baseProductionRate {
    switch (type) {
      case BuildingType.castle:
        return 0.10; // Küçük bir temel üretim (Soft-lock koruması)
      case BuildingType.corn:
        return 0.42;
      case BuildingType.lumberjack:
        return 0.35;
      case BuildingType.windmill:
        return 0.25;
      case BuildingType.sawmill:
        return 0.20;
      case BuildingType.bakery:
        return 0.25;
      case BuildingType.furniture:
        return 0.20;
      case BuildingType.mine:
        return 0.30;
      case BuildingType.fisherman:
        return 0.35;
      default:
        return 0.0;
    }
  }

  /// Temel taşıma kapasitesi (İşçiler için)
  double get baseCarryingCapacity {
    switch (type) {
      case BuildingType.worker:
        return 1.68; // 4 * 0.42 (Corn rate)
      case BuildingType.fishermanHut:
        return 1.40; // 4 * 0.35 (Fisherman rate)
      default:
        return 0.0;
    }
  }

  /// Seviyeye göre anlık üretim hızı
  double get currentProductionRate {
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

    final double milestoneBoost = math.pow(2.0, k).toDouble();
    return baseProductionRate * level * milestoneBoost;
  }

  /// Seviyeye göre anlık taşıma kapasitesi
  double get currentCarryingCapacity {
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

    final double milestoneBoost = math.pow(2.0, k).toDouble();
    return baseCarryingCapacity * level * milestoneBoost;
  }

  /// ROI / F/K Oranı (Saniye bazında)
  double get roiSeconds {
    final double nextLevelRate = _calculateRateForLevel(level + 1);
    final double deltaP = nextLevelRate - currentProductionRate;
    if (deltaP <= 0) {
      return 0;
    }
    return upgradeCost / deltaP;
  }

  double _calculateRateForLevel(int targetLevel) {
    int k = 0;
    if (targetLevel >= 200) {
      k = 5;
    } else if (targetLevel >= 100) {
      k = 4;
    } else if (targetLevel >= 50) {
      k = 3;
    } else if (targetLevel >= 25) {
      k = 2;
    } else if (targetLevel >= 10) {
      k = 1;
    }
    final double milestoneBoost = math.pow(2.0, k).toDouble();
    return baseProductionRate * targetLevel * milestoneBoost;
  }

  bool get isNextLevelMilestone {
    final int next = level + 1;
    return next == 10 || next == 25 || next == 50 || next == 100 || next == 200;
  }

  /// Bir sonraki eşiğe kalan seviye
  int get levelsToNextMilestone {
    if (level < 10) return 10 - level;
    if (level < 25) return 25 - level;
    if (level < 50) return 50 - level;
    if (level < 100) return 100 - level;
    if (level < 200) return 200 - level;
    return 0;
  }

  /// Maksimum birikim kapasitesi (otomasyonsuz durumda)
  double get maxCapacity => currentProductionRate * 30.0;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'level': level,
        'accumulated_resource': accumulatedResource,
        'total_gathered': totalGathered,
      };

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    final String typeName = json['type'] as String? ?? 'corn';
    final BuildingType bType = BuildingType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => BuildingType.corn,
    );
    return BuildingModel(
      type: bType,
      level: json['level'] as int? ?? 1,
      accumulatedResource:
          (json['accumulated_resource'] as num?)?.toDouble() ?? 0.0,
      totalGathered: (json['total_gathered'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory BuildingModel.fromLegacy(String bType, int bLvl, double bAccum) {
    BuildingType type = BuildingType.corn;
    if (bType == 'castle') type = BuildingType.castle;
    if (bType == 'corn') type = BuildingType.corn;
    if (bType == 'windmill') type = BuildingType.windmill;
    if (bType == 'bakery') type = BuildingType.bakery;
    if (bType == 'lumberjack') type = BuildingType.lumberjack;
    if (bType == 'sawmill') type = BuildingType.sawmill;
    if (bType == 'furniture') type = BuildingType.furniture;
    if (bType == 'worker') type = BuildingType.worker;
    if (bType == 'watchtower') type = BuildingType.watchtower;
    if (bType == 'mine') type = BuildingType.mine;
    if (bType == 'bridge') type = BuildingType.bridge;
    if (bType == 'fisherman') type = BuildingType.fisherman;
    if (bType == 'fishermanHut') type = BuildingType.fishermanHut;

    return BuildingModel(
      type: type,
      level: bLvl,
      accumulatedResource: bAccum,
    );
  }
}
