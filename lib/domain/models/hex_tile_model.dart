import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../services/symbiosis_engine.dart';
import 'ancestral_kurgan_model.dart';
import 'building_model.dart';
import 'combat_model.dart';

enum TileBiome {
  meadow,
  forest,
  mountain,
  sea,
  desert,
  tundra,
  volcano,
  wetland,
  celestialCrater,
  kurganValley,
  crystalChasm,
}

enum TileState {
  fog,
  discovered,
  owned,
}

enum ShrineType {
  none,
  foodBoost,
  woodBoost,
  stoneBoost,
  speedBoost,
}

extension ShrineTypeExtension on ShrineType {
  String get titleTr {
    switch (this) {
      case ShrineType.foodBoost:
        return 'Gıda Bereketi';
      case ShrineType.woodBoost:
        return 'Odun Bereketi';
      case ShrineType.stoneBoost:
        return 'Taş Bereketi';
      case ShrineType.speedBoost:
        return 'Lojistik Hızı';
      case ShrineType.none:
        return '';
    }
  }

  String get titleEn {
    switch (this) {
      case ShrineType.foodBoost:
        return 'Food Abundance';
      case ShrineType.woodBoost:
        return 'Wood Abundance';
      case ShrineType.stoneBoost:
        return 'Stone Abundance';
      case ShrineType.speedBoost:
        return 'Logistics Speed';
      case ShrineType.none:
        return '';
    }
  }

  double get boostPercentage => 200.0;

  double calculateBoostPercentage(int distance) => 200.0;

  double getBoostMultiplier(int distance) => 2.0;

  double get boostMultiplier => 2.0;

  String get formattedBonusTr => 'x2 $titleTr (+%200)';
  String get formattedBonusEn => 'x2 $titleEn (+200%)';

  String getFormattedBonusTr(int distance, [double multiplierVal = 2.0]) {
    final String multText = multiplierVal >= 3.0 ? 'x3 (3 Kat)' : 'x2 (2 Kat)';
    final int pct = (multiplierVal * 100).toInt();
    return '$multText $titleTr (+%$pct)';
  }

  String getFormattedBonusEn(int distance, [double multiplierVal = 2.0]) {
    final String multText = multiplierVal >= 3.0 ? 'x3 (3x)' : 'x2 (2x)';
    final int pct = (multiplierVal * 100).toInt();
    return '$multText $titleEn (+$pct%)';
  }
}

class HexTileModel {
  final HexAxial coord;
  final TileBiome biome;
  final TileState state;
  final BuildingModel? building;
  final bool isWarmed;
  final double warmTimer;
  final ShrineType shrine;
  final double shrineMultiplierValue; // 2.0 (x2) or 3.0 (x3)
  final double soilHealth; // 0.0 to 1.0 (1.0 = fresh soil, 0.0 = exhausted)
  final bool isResting; // True when placed in transhumance pasture rest
  final double restTimeAccumulated; // Seconds spent resting, used for respiration burst
  final SymbiosisType symbiosis; // Cascading ecological hybrid state
  final AncestralKurgan? ancestralKurgan; // Ancient relic tomb from previous migration
  final bool isDamaged; // Düşman akınında tahrip edilmiş karo
  final CombatWallModel? wall; // Karodaki sur yapısı
  final bool isAutoHeatEnabled; // Kış soğuğunda otomatik ısıtma devresi (Auto-Heat)

  const HexTileModel({
    required this.coord,
    required this.biome,
    required this.state,
    this.building,
    this.isWarmed = false,
    this.warmTimer = 0.0,
    this.shrine = ShrineType.none,
    this.shrineMultiplierValue = 2.0,
    this.soilHealth = 1.0,
    this.isResting = false,
    this.restTimeAccumulated = 0.0,
    this.symbiosis = SymbiosisType.none,
    this.ancestralKurgan,
    this.isDamaged = false,
    this.wall,
    this.isAutoHeatEnabled = false,
  });

  bool get hasBuilding => building != null;
  bool get isOwned => state == TileState.owned;
  bool get isDiscovered => state == TileState.discovered;
  bool get isFog => state == TileState.fog;
  bool get hasShrine => shrine != ShrineType.none;
  bool get hasKurgan => ancestralKurgan != null;
  bool get isSymbiotic => symbiosis != SymbiosisType.none;
  bool get hasActiveWall => wall != null && !wall!.isBreached;
  bool get needsRepair => isDamaged || (wall != null && wall!.needsRepair);

  int get distanceFromCenter => HexMath.hexDistance(const HexAxial(0, 0), coord);
  double get shrineBonusPercentage => shrine == ShrineType.none ? 0.0 : (shrineMultiplierValue * 100.0);
  double get shrineBoostMultiplier => shrine == ShrineType.none ? 0.0 : (shrineMultiplierValue - 1.0);
  String get formattedShrineBonusTr => shrine.getFormattedBonusTr(distanceFromCenter, shrineMultiplierValue);
  String get formattedShrineBonusEn => shrine.getFormattedBonusEn(distanceFromCenter, shrineMultiplierValue);

  HexTileModel copyWith({
    HexAxial? coord,
    TileBiome? biome,
    TileState? state,
    BuildingModel? building,
    bool? clearBuilding,
    bool? isWarmed,
    double? warmTimer,
    ShrineType? shrine,
    double? shrineMultiplierValue,
    double? soilHealth,
    bool? isResting,
    double? restTimeAccumulated,
    SymbiosisType? symbiosis,
    AncestralKurgan? ancestralKurgan,
    bool? clearKurgan,
    bool? isDamaged,
    CombatWallModel? wall,
    bool? clearWall,
    bool? isAutoHeatEnabled,
  }) {
    return HexTileModel(
      coord: coord ?? this.coord,
      biome: biome ?? this.biome,
      state: state ?? this.state,
      building: clearBuilding == true ? null : (building ?? this.building),
      isWarmed: isWarmed ?? this.isWarmed,
      warmTimer: warmTimer ?? this.warmTimer,
      shrine: shrine ?? this.shrine,
      shrineMultiplierValue: shrineMultiplierValue ?? this.shrineMultiplierValue,
      soilHealth: soilHealth ?? this.soilHealth,
      isResting: isResting ?? this.isResting,
      restTimeAccumulated: restTimeAccumulated ?? this.restTimeAccumulated,
      symbiosis: symbiosis ?? this.symbiosis,
      ancestralKurgan: clearKurgan == true ? null : (ancestralKurgan ?? this.ancestralKurgan),
      isDamaged: isDamaged ?? this.isDamaged,
      wall: clearWall == true ? null : (wall ?? this.wall),
      isAutoHeatEnabled: isAutoHeatEnabled ?? this.isAutoHeatEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': coord.q,
      'y': coord.r,
      'type': biome.index,
      'state': state.index,
      'building': building?.toJson(),
      'is_warmed': isWarmed,
      'warm_timer': warmTimer,
      'shrine': shrine.index,
      'shrine_mult': shrineMultiplierValue,
      'soil_health': soilHealth,
      'is_resting': isResting,
      'rest_time_accumulated': restTimeAccumulated,
      'symbiosis': symbiosis.index,
      'ancestral_kurgan': ancestralKurgan?.toJson(),
      'is_damaged': isDamaged,
      'wall': wall?.toJson(),
      'is_auto_heat_enabled': isAutoHeatEnabled,
    };
  }

  factory HexTileModel.fromJson(Map<String, dynamic> json) {
    final int q = json['x'] as int? ?? json['q'] as int? ?? 0;
    final int r = json['y'] as int? ?? json['r'] as int? ?? 0;
    final int biomeIdx = json['type'] as int? ?? 0;
    final int stateIdx = json['state'] as int? ?? 0;
    final int shrineIdx = json['shrine'] as int? ?? 0;
    final double shrineMult = (json['shrine_mult'] as num?)?.toDouble() ?? 2.0;
    final int symbiosisIdx = json['symbiosis'] as int? ?? 0;

    BuildingModel? b;
    if (json.containsKey('building') && json['building'] != null) {
      b = BuildingModel.fromJson(json['building'] as Map<String, dynamic>);
    } else if (json.containsKey('building_type') &&
        (json['building_type'] as String).isNotEmpty) {
      final String bType = json['building_type'] as String;
      final int bLvl = json['building_level'] as int? ?? 1;
      final double bAccum = (json['building_accum'] as num?)?.toDouble() ?? 0.0;
      b = BuildingModel.fromLegacy(bType, bLvl, bAccum);
    }

    AncestralKurgan? kurgan;
    if (json.containsKey('ancestral_kurgan') && json['ancestral_kurgan'] != null) {
      kurgan = AncestralKurgan.fromJson(json['ancestral_kurgan'] as Map<String, dynamic>);
    }

    CombatWallModel? wall;
    if (json.containsKey('wall') && json['wall'] != null) {
      wall = CombatWallModel.fromJson(json['wall'] as Map<String, dynamic>);
    }

    return HexTileModel(
      coord: HexAxial(q, r),
      biome: TileBiome.values[biomeIdx.clamp(0, TileBiome.values.length - 1)],
      state: TileState.values[stateIdx.clamp(0, TileState.values.length - 1)],
      building: b,
      isWarmed: json['is_warmed'] as bool? ?? false,
      warmTimer: (json['warm_timer'] as num?)?.toDouble() ?? 0.0,
      shrine: ShrineType.values[shrineIdx.clamp(0, ShrineType.values.length - 1)],
      shrineMultiplierValue: shrineMult,
      soilHealth: (json['soil_health'] as num?)?.toDouble() ?? 1.0,
      isResting: json['is_resting'] as bool? ?? false,
      restTimeAccumulated: (json['rest_time_accumulated'] as num?)?.toDouble() ?? 0.0,
      symbiosis: SymbiosisType.values[symbiosisIdx.clamp(0, SymbiosisType.values.length - 1)],
      ancestralKurgan: kurgan,
      isDamaged: json['is_damaged'] as bool? ?? false,
      wall: wall,
      isAutoHeatEnabled: json['is_auto_heat_enabled'] as bool? ?? false,
    );
  }
}

