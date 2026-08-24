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
    }
  }

  double get costGrowthFactor => 1.15;

  /// Seviye yükseltme maliyeti
  double get upgradeCost => baseCost * math.pow(costGrowthFactor, level - 1);

  /// Temel üretim hızı (birim/saniye)
  double get baseProductionRate {
    switch (type) {
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
      default:
        return 0.0;
    }
  }

  /// Seviyeye göre anlık üretim hızı
  double get currentProductionRate =>
      baseProductionRate * math.pow(1.5, level - 1);

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

    return BuildingModel(
      type: type,
      level: bLvl,
      accumulatedResource: bAccum,
    );
  }
}
