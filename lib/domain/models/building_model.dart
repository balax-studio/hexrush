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
  shrine,
}

class BuildingModel {
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
      case BuildingType.shrine:
        return 0.0;
    }
  }

  double get costGrowthFactor => 1.15;

  /// Seviye yükseltme maliyeti
  double get upgradeCost => baseCost * math.pow(costGrowthFactor, level - 1);

  /// Temel üretim hızı (birim/saniye)
  double get baseProductionRate {
    switch (type) {
      case BuildingType.castle:
        return 0.10;
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
        return 1.68;
      case BuildingType.fishermanHut:
        return 1.40;
      default:
        return 0.0;
    }
  }

  /// Seviyeye göre anlık üretim hızı
  double get currentProductionRate {
    int k = 0;
    if (level >= 200) k = 5;
    else if (level >= 100) k = 4;
    else if (level >= 50) k = 3;
    else if (level >= 25) k = 2;
    else if (level >= 10) k = 1;

    final double milestoneBoost = math.pow(2.0, k).toDouble();
    return baseProductionRate * level * milestoneBoost;
  }

  /// Seviyeye göre anlık taşıma kapasitesi
  double get currentCarryingCapacity {
    int k = 0;
    if (level >= 200) k = 5;
    else if (level >= 100) k = 4;
    else if (level >= 50) k = 3;
    else if (level >= 25) k = 2;
    else if (level >= 10) k = 1;

    final double milestoneBoost = math.pow(2.0, k).toDouble();
    return baseCarryingCapacity * level * milestoneBoost;
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
    else if (bType == 'corn') type = BuildingType.corn;
    else if (bType == 'windmill') type = BuildingType.windmill;
    else if (bType == 'bakery') type = BuildingType.bakery;
    else if (bType == 'lumberjack') type = BuildingType.lumberjack;
    else if (bType == 'sawmill') type = BuildingType.sawmill;
    else if (bType == 'furniture') type = BuildingType.furniture;
    else if (bType == 'worker') type = BuildingType.worker;
    else if (bType == 'watchtower') type = BuildingType.watchtower;
    else if (bType == 'mine') type = BuildingType.mine;
    else if (bType == 'bridge') type = BuildingType.bridge;
    else if (bType == 'fisherman') type = BuildingType.fisherman;
    else if (bType == 'fishermanHut') type = BuildingType.fishermanHut;
    else if (bType == 'shrine') type = BuildingType.shrine;

    return BuildingModel(
      type: type,
      level: bLvl,
      accumulatedResource: bAccum,
    );
  }
}
