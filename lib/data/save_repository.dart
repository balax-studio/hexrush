import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/game_state_model.dart';
import '../domain/models/hex_tile_model.dart';

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
      final Map<String, dynamic> data =
          jsonDecode(rawJson) as Map<String, dynamic>;
      final int timestamp = data['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final resources = data.containsKey('resources')
          ? ResourcesModel.fromJson(data['resources'] as Map<String, dynamic>)
          : const ResourcesModel();

      final progression = data.containsKey('progression')
          ? ProgressionModel.fromJson(
              data['progression'] as Map<String, dynamic>)
          : const ProgressionModel();

      final season = data.containsKey('season')
          ? SeasonModel.fromJson(data['season'] as Map<String, dynamic>)
          : const SeasonModel();

      final settings = data.containsKey('settings')
          ? SettingsModel.fromJson(data['settings'] as Map<String, dynamic>)
          : const SettingsModel();

      final List<HexTileModel> tiles = [];
      if (data.containsKey('tiles') && data['tiles'] is List) {
        for (final item in (data['tiles'] as List)) {
          if (item is Map<String, dynamic>) {
            tiles.add(HexTileModel.fromJson(item));
          }
        }
      }

      final toreTalents =
          data['tore']?['tore_talents'] as Map<String, dynamic>? ?? {};
      final titles = data['titles'] as Map<String, dynamic>? ?? {};
      final stats = data['stats'] as Map<String, dynamic>? ?? {};

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
    };

    return prefs.setString(_saveKey, jsonEncode(data));
  }

  /// Kayıt dosyasını siler
  static Future<bool> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_saveKey);
  }
}
