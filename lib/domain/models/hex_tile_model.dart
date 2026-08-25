import '../../core/hex/hex_coordinates.dart';
import 'building_model.dart';

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
  speedBoost,
}

class HexTileModel {
  final HexAxial coord;
  final TileBiome biome;
  final TileState state;
  final BuildingModel? building;
  final bool isWarmed;
  final double warmTimer;
  final ShrineType shrine;

  const HexTileModel({
    required this.coord,
    required this.biome,
    required this.state,
    this.building,
    this.isWarmed = false,
    this.warmTimer = 0.0,
    this.shrine = ShrineType.none,
  });

  bool get hasBuilding => building != null;
  bool get isOwned => state == TileState.owned;
  bool get isDiscovered => state == TileState.discovered;
  bool get isFog => state == TileState.fog;
  bool get hasShrine => shrine != ShrineType.none;

  HexTileModel copyWith({
    HexAxial? coord,
    TileBiome? biome,
    TileState? state,
    BuildingModel? building,
    bool? clearBuilding,
    bool? isWarmed,
    double? warmTimer,
    ShrineType? shrine,
  }) {
    return HexTileModel(
      coord: coord ?? this.coord,
      biome: biome ?? this.biome,
      state: state ?? this.state,
      building: clearBuilding == true ? null : (building ?? this.building),
      isWarmed: isWarmed ?? this.isWarmed,
      warmTimer: warmTimer ?? this.warmTimer,
      shrine: shrine ?? this.shrine,
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
    };
  }

  factory HexTileModel.fromJson(Map<String, dynamic> json) {
    final int q = json['x'] as int? ?? json['q'] as int? ?? 0;
    final int r = json['y'] as int? ?? json['r'] as int? ?? 0;
    final int biomeIdx = json['type'] as int? ?? 0;
    final int stateIdx = json['state'] as int? ?? 0;
    final int shrineIdx = json['shrine'] as int? ?? 0;

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

    return HexTileModel(
      coord: HexAxial(q, r),
      biome: TileBiome.values[biomeIdx.clamp(0, TileBiome.values.length - 1)],
      state: TileState.values[stateIdx.clamp(0, TileState.values.length - 1)],
      building: b,
      isWarmed: json['is_warmed'] as bool? ?? false,
      warmTimer: (json['warm_timer'] as num?)?.toDouble() ?? 0.0,
      shrine: ShrineType.values[shrineIdx.clamp(0, ShrineType.values.length - 1)],
    );
  }
}
