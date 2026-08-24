import '../../core/hex/hex_coordinates.dart';
import 'game_state_model.dart';
import 'hex_tile_model.dart';

class GameState {
  final Map<HexAxial, HexTileModel> tiles;
  final ResourcesModel resources;
  final ProgressionModel progression;
  final SeasonModel season;
  final SettingsModel settings;
  final HexAxial? selectedCoord;
  final String? activeToast;
  final int frenzyMultiplier;
  final double frenzyTimer;
  final Map<String, dynamic> toreTalents;
  final Map<String, dynamic> titles;
  final Map<String, dynamic> stats;

  const GameState({
    required this.tiles,
    this.resources = const ResourcesModel(),
    this.progression = const ProgressionModel(),
    this.season = const SeasonModel(),
    this.settings = const SettingsModel(),
    this.selectedCoord,
    this.activeToast,
    this.frenzyMultiplier = 1,
    this.frenzyTimer = 0.0,
    this.toreTalents = const {},
    this.titles = const {},
    this.stats = const {},
  });

  GameState copyWith({
    Map<HexAxial, HexTileModel>? tiles,
    ResourcesModel? resources,
    ProgressionModel? progression,
    SeasonModel? season,
    SettingsModel? settings,
    HexAxial? selectedCoord,
    bool clearSelection = false,
    String? activeToast,
    bool clearToast = false,
    int? frenzyMultiplier,
    double? frenzyTimer,
    Map<String, dynamic>? toreTalents,
    Map<String, dynamic>? titles,
    Map<String, dynamic>? stats,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      resources: resources ?? this.resources,
      progression: progression ?? this.progression,
      season: season ?? this.season,
      settings: settings ?? this.settings,
      selectedCoord: clearSelection ? null : (selectedCoord ?? this.selectedCoord),
      activeToast: clearToast ? null : (activeToast ?? this.activeToast),
      frenzyMultiplier: frenzyMultiplier ?? this.frenzyMultiplier,
      frenzyTimer: frenzyTimer ?? this.frenzyTimer,
      toreTalents: toreTalents ?? this.toreTalents,
      titles: titles ?? this.titles,
      stats: stats ?? this.stats,
    );
  }
}
