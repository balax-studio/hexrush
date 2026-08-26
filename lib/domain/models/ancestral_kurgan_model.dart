import 'package:flutter/foundation.dart';
import '../../core/hex/hex_coordinates.dart';
import 'building_model.dart';

@immutable
class AncestralKurgan {
  final String id;
  final HexAxial coord;
  final BuildingType formerBuildingType;
  final int formerLevel;
  final bool isDiscovered;
  final String relicTitle;
  final double bonusMultiplier; // e.g. 0.35 (+35% global prestige echo)

  const AncestralKurgan({
    required this.id,
    required this.coord,
    required this.formerBuildingType,
    required this.formerLevel,
    this.isDiscovered = false,
    required this.relicTitle,
    this.bonusMultiplier = 0.35,
  });

  AncestralKurgan copyWith({
    String? id,
    HexAxial? coord,
    BuildingType? formerBuildingType,
    int? formerLevel,
    bool? isDiscovered,
    String? relicTitle,
    double? bonusMultiplier,
  }) {
    return AncestralKurgan(
      id: id ?? this.id,
      coord: coord ?? this.coord,
      formerBuildingType: formerBuildingType ?? this.formerBuildingType,
      formerLevel: formerLevel ?? this.formerLevel,
      isDiscovered: isDiscovered ?? this.isDiscovered,
      relicTitle: relicTitle ?? this.relicTitle,
      bonusMultiplier: bonusMultiplier ?? this.bonusMultiplier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'q': coord.q,
      'r': coord.r,
      'former_building_type': formerBuildingType.name,
      'former_level': formerLevel,
      'is_discovered': isDiscovered,
      'relic_title': relicTitle,
      'bonus_multiplier': bonusMultiplier,
    };
  }

  factory AncestralKurgan.fromJson(Map<String, dynamic> json) {
    final typeName = json['former_building_type'] as String? ?? 'castle';
    final bType = BuildingType.values.firstWhere(
      (b) => b.name == typeName,
      orElse: () => BuildingType.castle,
    );

    return AncestralKurgan(
      id: json['id'] as String,
      coord: HexAxial(json['q'] as int, json['r'] as int),
      formerBuildingType: bType,
      formerLevel: json['former_level'] as int? ?? 1,
      isDiscovered: json['is_discovered'] as bool? ?? false,
      relicTitle: json['relic_title'] as String? ?? 'Ata Mirası Balbalı',
      bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 0.35,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AncestralKurgan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          coord == other.coord &&
          isDiscovered == other.isDiscovered &&
          relicTitle == other.relicTitle;

  @override
  int get hashCode => Object.hash(id, coord, isDiscovered, relicTitle);
}
