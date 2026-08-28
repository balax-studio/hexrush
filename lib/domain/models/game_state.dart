import '../../core/hex/hex_coordinates.dart';
import '../economy/economy_calculator.dart';
import 'ad_reward_model.dart';
import 'ancestral_kurgan_model.dart';
import 'caravan_route_model.dart';
import 'celestial_omen_model.dart';
import 'combat_model.dart';
import 'doctrine_model.dart';
import 'game_state_model.dart';
import 'hex_tile_model.dart';
import 'quest_model.dart';

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
  final double seasonLerpProgress; // 0.0 to 1.0 (60s lerp)
  final double shrineMultiplier;
  final List<QuestModel> quests;
  final String? activeQuestId;
  final List<DoctrineCardModel> doctrines;
  final Map<DoctrineSlotType, String?> activeDoctrineSlots;
  final List<CaravanRoute> caravanRoutes;
  final CelestialOmen celestialOmen;
  final int yearIndex;
  final int rhythmCombo;
  final double rhythmMultiplier;
  final double lastRhythmTapTime;
  final bool isMacroOverview;
  final bool isDioramaMode;
  final List<AncestralKurgan> discoveredKurgans;
  final AdRewardTracking adTracking;
  final OfflineGainsResult? pendingOfflineGains;
  final CombatState combatState;

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
    this.seasonLerpProgress = 1.0,
    this.shrineMultiplier = 1.0,
    this.quests = const [],
    this.activeQuestId,
    this.doctrines = const [],
    this.activeDoctrineSlots = const {
      DoctrineSlotType.economic: 'doc_sulama_fermani',
      DoctrineSlotType.military: 'doc_bozkir_akincisi',
      DoctrineSlotType.nomadic: 'doc_kis_otagi',
      DoctrineSlotType.wildcard: null,
    },
    this.caravanRoutes = const [],
    this.celestialOmen = const CelestialOmen(
      animal: CelestialAnimal.horse,
      title: 'At Yılı',
      description: 'Bozkır kervanları ve toplayıcılar %50 daha hızlı hareket eder.',
      workerSpeedMultiplier: 1.5,
      meatMultiplier: 1.25,
    ),
    this.yearIndex = 0,
    this.rhythmCombo = 0,
    this.rhythmMultiplier = 1.0,
    this.lastRhythmTapTime = 0.0,
    this.isMacroOverview = false,
    this.isDioramaMode = false,
    this.discoveredKurgans = const [],
    this.adTracking = const AdRewardTracking(),
    this.pendingOfflineGains,
    this.combatState = const CombatState(),
  });

  QuestModel? get currentActiveQuest {
    if (quests.isEmpty) return null;
    if (activeQuestId != null) {
      final match = quests.where((q) => q.id == activeQuestId).firstOrNull;
      if (match != null && !match.isClaimed) return match;
    }
    return quests.where((q) => !q.isClaimed).firstOrNull;
  }

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
    double? seasonLerpProgress,
    double? shrineMultiplier,
    List<QuestModel>? quests,
    String? activeQuestId,
    List<DoctrineCardModel>? doctrines,
    Map<DoctrineSlotType, String?>? activeDoctrineSlots,
    List<CaravanRoute>? caravanRoutes,
    CelestialOmen? celestialOmen,
    int? yearIndex,
    int? rhythmCombo,
    double? rhythmMultiplier,
    double? lastRhythmTapTime,
    bool? isMacroOverview,
    bool? isDioramaMode,
    List<AncestralKurgan>? discoveredKurgans,
    AdRewardTracking? adTracking,
    OfflineGainsResult? pendingOfflineGains,
    bool clearPendingOfflineGains = false,
    CombatState? combatState,
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
      seasonLerpProgress: seasonLerpProgress ?? this.seasonLerpProgress,
      shrineMultiplier: shrineMultiplier ?? this.shrineMultiplier,
      quests: quests ?? this.quests,
      activeQuestId: activeQuestId ?? this.activeQuestId,
      doctrines: doctrines ?? this.doctrines,
      activeDoctrineSlots: activeDoctrineSlots ?? this.activeDoctrineSlots,
      caravanRoutes: caravanRoutes ?? this.caravanRoutes,
      celestialOmen: celestialOmen ?? this.celestialOmen,
      yearIndex: yearIndex ?? this.yearIndex,
      rhythmCombo: rhythmCombo ?? this.rhythmCombo,
      rhythmMultiplier: rhythmMultiplier ?? this.rhythmMultiplier,
      lastRhythmTapTime: lastRhythmTapTime ?? this.lastRhythmTapTime,
      isMacroOverview: isMacroOverview ?? this.isMacroOverview,
      isDioramaMode: isDioramaMode ?? this.isDioramaMode,
      discoveredKurgans: discoveredKurgans ?? this.discoveredKurgans,
      adTracking: adTracking ?? this.adTracking,
      pendingOfflineGains: clearPendingOfflineGains ? null : (pendingOfflineGains ?? this.pendingOfflineGains),
      combatState: combatState ?? this.combatState,
    );
  }
}


