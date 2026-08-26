import 'package:flutter/foundation.dart';
import '../../core/hex/hex_coordinates.dart';

@immutable
class CaravanRoute {
  final String id;
  final HexAxial startCoord;
  final HexAxial endCoord;
  final String synergyType; // e.g. 'OASIS_FORGE', 'WOOD_STONE', 'GENERAL'
  final double bonusMultiplier; // e.g. 0.25 (+25%)
  final double progress; // 0.0 to 1.0 for voxel convoy positioning
  final int level;

  const CaravanRoute({
    required this.id,
    required this.startCoord,
    required this.endCoord,
    this.synergyType = 'GENERAL',
    this.bonusMultiplier = 0.25,
    this.progress = 0.0,
    this.level = 1,
  });

  CaravanRoute copyWith({
    String? id,
    HexAxial? startCoord,
    HexAxial? endCoord,
    String? synergyType,
    double? bonusMultiplier,
    double? progress,
    int? level,
  }) {
    return CaravanRoute(
      id: id ?? this.id,
      startCoord: startCoord ?? this.startCoord,
      endCoord: endCoord ?? this.endCoord,
      synergyType: synergyType ?? this.synergyType,
      bonusMultiplier: bonusMultiplier ?? this.bonusMultiplier,
      progress: progress ?? this.progress,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_q': startCoord.q,
      'start_r': startCoord.r,
      'end_q': endCoord.q,
      'end_r': endCoord.r,
      'synergy_type': synergyType,
      'bonus_multiplier': bonusMultiplier,
      'progress': progress,
      'level': level,
    };
  }

  factory CaravanRoute.fromJson(Map<String, dynamic> json) {
    return CaravanRoute(
      id: json['id'] as String,
      startCoord: HexAxial(json['start_q'] as int, json['start_r'] as int),
      endCoord: HexAxial(json['end_q'] as int, json['end_r'] as int),
      synergyType: json['synergy_type'] as String? ?? 'GENERAL',
      bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 0.25,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaravanRoute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startCoord == other.startCoord &&
          endCoord == other.endCoord &&
          synergyType == other.synergyType &&
          bonusMultiplier == other.bonusMultiplier &&
          progress == other.progress &&
          level == other.level;

  @override
  int get hashCode => Object.hash(id, startCoord, endCoord, synergyType, bonusMultiplier, progress, level);
}
