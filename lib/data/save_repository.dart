import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

      final toreTalents = data['tore'] is Map && (data['tore'] as Map)['tore_talents'] is Map
          ? Map<String, dynamic>.from((data['tore'] as Map)['tore_talents'] as Map)
          : <String, dynamic>{};
      final titles = data['titles'] is Map
          ? Map<String, dynamic>.from(data['titles'] as Map)
          : <String, dynamic>{};
      final stats = data['stats'] is Map
          ? Map<String, dynamic>.from(data['stats'] as Map)
          : <String, dynamic>{};

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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'version': 2,
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
    };

    return prefs.setString(_saveKey, jsonEncode(data));
  }

  /// Kayıt dosyasını siler
  static Future<bool> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_saveKey);
  }
}
