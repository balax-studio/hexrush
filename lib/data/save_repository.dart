import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/ad_reward_model.dart';
import '../domain/models/ancestral_kurgan_model.dart';
import '../domain/models/caravan_route_model.dart';
import '../domain/models/celestial_omen_model.dart';
import '../domain/models/doctrine_model.dart';
import '../domain/models/game_state_model.dart';
import '../domain/models/hex_tile_model.dart';
import '../domain/models/quest_model.dart';

class SaveDataBundle {
  final int timestamp;
  final ResourcesModel resources;
  final ProgressionModel progression;
  final SeasonModel season;
  final SettingsModel settings;
  final List<HexTileModel> tiles;
  final Map<String, dynamic> toreTalents;
  final Map<String, dynamic> titles;
  final Map<String, dynamic> stats;
  final List<QuestModel> quests;
  final List<DoctrineCardModel> doctrines;
  final Map<DoctrineSlotType, String?> activeDoctrineSlots;
  final List<CaravanRoute> caravanRoutes;
  final CelestialOmen? celestialOmen;
  final int yearIndex;
  final List<AncestralKurgan> discoveredKurgans;
  final AdRewardTracking adTracking;

  const SaveDataBundle({
    required this.timestamp,
    required this.resources,
    required this.progression,
    required this.season,
    required this.settings,
    required this.tiles,
    this.toreTalents = const {},
    this.titles = const {},
    this.stats = const {},
    this.quests = const [],
    this.doctrines = const [],
    this.activeDoctrineSlots = const {},
    this.caravanRoutes = const [],
    this.celestialOmen,
    this.yearIndex = 0,
    this.discoveredKurgans = const [],
    this.adTracking = const AdRewardTracking(),
  });
}

class SaveRepository {
  static const String _saveKey = 'hex_idle_save_v1';

  /// Kayıtlı veriyi SharedPreferences üzerinden çeker
  static Future<SaveDataBundle?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_saveKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map) return null;
      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

      final int timestamp = data['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final resources = data['resources'] is Map
          ? ResourcesModel.fromJson(Map<String, dynamic>.from(data['resources'] as Map))
          : const ResourcesModel();

      final progression = data['progression'] is Map
          ? ProgressionModel.fromJson(Map<String, dynamic>.from(data['progression'] as Map))
          : const ProgressionModel();

      final season = data['season'] is Map
          ? SeasonModel.fromJson(Map<String, dynamic>.from(data['season'] as Map))
          : const SeasonModel();

      final settings = data['settings'] is Map
          ? SettingsModel.fromJson(Map<String, dynamic>.from(data['settings'] as Map))
          : const SettingsModel();

      final List<HexTileModel> tiles = [];
      if (data['tiles'] is List) {
        for (final item in (data['tiles'] as List)) {
          if (item is Map) {
            try {
              tiles.add(HexTileModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
      }

      final List<QuestModel> quests = [];
      if (data['quests'] is List) {
        for (final item in (data['quests'] as List)) {
          if (item is Map) {
            try {
              quests.add(QuestModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
      }

      final List<DoctrineCardModel> doctrines = [];
      if (data['doctrines'] is List) {
        for (final item in (data['doctrines'] as List)) {
          if (item is Map) {
            try {
              doctrines.add(DoctrineCardModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
      }

      final Map<DoctrineSlotType, String?> activeSlots = {};
      if (data['active_doctrine_slots'] is Map) {
        final rawSlots = Map<String, dynamic>.from(data['active_doctrine_slots'] as Map);
        for (final slot in DoctrineSlotType.values) {
          if (rawSlots.containsKey(slot.name)) {
            activeSlots[slot] = rawSlots[slot.name] as String?;
          }
        }
      }

      final List<CaravanRoute> caravanRoutes = [];
      if (data['caravan_routes'] is List) {
        for (final item in (data['caravan_routes'] as List)) {
          if (item is Map) {
            try {
              caravanRoutes.add(CaravanRoute.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
      }

      CelestialOmen? omen;
      if (data['celestial_omen'] is Map) {
        try {
          omen = CelestialOmen.fromJson(Map<String, dynamic>.from(data['celestial_omen'] as Map));
        } catch (_) {}
      }

      final int yearIndex = data['year_index'] as int? ?? 0;

      final List<AncestralKurgan> discoveredKurgans = [];
      if (data['discovered_kurgans'] is List) {
        for (final item in (data['discovered_kurgans'] as List)) {
          if (item is Map) {
            try {
              discoveredKurgans.add(AncestralKurgan.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
      }

      final toreTalents = data['tore'] is Map && (data['tore'] as Map)['tore_talents'] is Map
          ? Map<String, dynamic>.from((data['tore'] as Map)['tore_talents'] as Map)
          : <String, dynamic>{};
      final titles = data['titles'] is Map
          ? Map<String, dynamic>.from(data['titles'] as Map)
          : <String, dynamic>{};
      final stats = data['stats'] is Map
          ? Map<String, dynamic>.from(data['stats'] as Map)
          : <String, dynamic>{};

      final adTracking = data['ad_tracking'] is Map
          ? AdRewardTracking.fromJson(Map<String, dynamic>.from(data['ad_tracking'] as Map))
          : const AdRewardTracking();

      return SaveDataBundle(
        timestamp: timestamp,
        resources: resources,
        progression: progression,
        season: season,
        settings: settings,
        tiles: tiles,
        toreTalents: toreTalents,
        titles: titles,
        stats: stats,
        quests: quests,
        doctrines: doctrines,
        activeDoctrineSlots: activeSlots,
        caravanRoutes: caravanRoutes,
        celestialOmen: omen,
        yearIndex: yearIndex,
        discoveredKurgans: discoveredKurgans,
        adTracking: adTracking,
      );
    } catch (e) {
      // JSON parse error fallback
      return null;
    }
  }

  /// Oyunu SharedPreferences içine kaydeder
  static Future<bool> saveGame({
    required ResourcesModel resources,
    required ProgressionModel progression,
    required SeasonModel season,
    required SettingsModel settings,
    required List<HexTileModel> tiles,
    Map<String, dynamic> toreTalents = const {},
    Map<String, dynamic> titles = const {},
    Map<String, dynamic> stats = const {},
    List<QuestModel> quests = const [],
    List<DoctrineCardModel> doctrines = const [],
    Map<DoctrineSlotType, String?> activeDoctrineSlots = const {},
    List<CaravanRoute> caravanRoutes = const [],
    CelestialOmen? celestialOmen,
    int yearIndex = 0,
    List<AncestralKurgan> discoveredKurgans = const [],
    AdRewardTracking adTracking = const AdRewardTracking(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final slotsJson = <String, String?>{};
    activeDoctrineSlots.forEach((k, v) {
      slotsJson[k.name] = v;
    });

    final data = {
      'version': 4,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'resources': resources.toJson(),
      'progression': progression.toJson(),
      'season': season.toJson(),
      'settings': settings.toJson(),
      'tiles': tiles.map((t) => t.toJson()).toList(),
      'tore': {'tore_talents': toreTalents},
      'titles': titles,
      'stats': stats,
      'quests': quests.map((q) => q.toJson()).toList(),
      'doctrines': doctrines.map((d) => d.toJson()).toList(),
      'active_doctrine_slots': slotsJson,
      'caravan_routes': caravanRoutes.map((c) => c.toJson()).toList(),
      'celestial_omen': celestialOmen?.toJson(),
      'year_index': yearIndex,
      'discovered_kurgans': discoveredKurgans.map((k) => k.toJson()).toList(),
      'ad_tracking': adTracking.toJson(),
    };

    return prefs.setString(_saveKey, jsonEncode(data));
  }

  /// Kayıt dosyasını siler
  static Future<bool> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_saveKey);
  }
}

