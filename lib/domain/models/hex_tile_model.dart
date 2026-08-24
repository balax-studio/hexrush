import '../../core/hex/hex_coordinates.dart';
import 'building_model.dart';

enum TileBiome {
  meadow,
  forest,
  mountain,
  sea,
}

enum TileState {
  fog,
  discovered,
  owned,
}

class HexTileModel {
  final HexAxial coord;
  final TileBiome biome;
  final TileState state;
  final BuildingModel? building;
  final bool isWarmed;
  final double warmTimer;

  const HexTileModel({
    required this.coord,
    required this.biome,
    required this.state,
    this.building,
    this.isWarmed = false,
    this.warmTimer = 0.0,
  });

  bool get hasBuilding => building != null;
  bool get isOwned => state == TileState.owned;
  bool get isDiscovered => state == TileState.discovered;
  bool get isFog => state == TileState.fog;

  HexTileModel copyWith({
    HexAxial? coord,
    TileBiome? biome,
    TileState? state,
    BuildingModel? building,
    bool? clearBuilding,
    bool? isWarmed,
    double? warmTimer,
  }) {
    return HexTileModel(
      coord: coord ?? this.coord,
      biome: biome ?? this.biome,
      state: state ?? this.state,
      building: clearBuilding == true ? null : (building ?? this.building),
      isWarmed: isWarmed ?? this.isWarmed,
      warmTimer: warmTimer ?? this.warmTimer,
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
    };
  }

  factory HexTileModel.fromJson(Map<String, dynamic> json) {
    final int q = json['x'] as int? ?? json['q'] as int? ?? 0;
    final int r = json['y'] as int? ?? json['r'] as int? ?? 0;
    final int biomeIdx = json['type'] as int? ?? 0;
    final int stateIdx = json['state'] as int? ?? 0;

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
    );
  }
}
