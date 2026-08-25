class ResourcesModel {
  final double food;
  final double wood;
  final double fish;
  final double flour;
  final double plank;
  final double bread;
  final double furniture;
  final double stone;
  final double iron;
  final double obsidian;
  final double mithril;
  final int crowns;
  final int tamgas;

  const ResourcesModel({
    this.food = 0.0,
    this.wood = 0.0,
    this.fish = 0.0,
    this.flour = 0.0,
    this.plank = 0.0,
    this.bread = 0.0,
    this.furniture = 0.0,
    this.stone = 0.0,
    this.iron = 0.0,
    this.obsidian = 0.0,
    this.mithril = 0.0,
    this.crowns = 0,
    this.tamgas = 0,
  });

  ResourcesModel copyWith({
    double? food,
    double? wood,
    double? fish,
    double? flour,
    double? plank,
    double? bread,
    double? furniture,
    double? stone,
    double? iron,
    double? obsidian,
    double? mithril,
    int? crowns,
    int? tamgas,
  }) {
    return ResourcesModel(
      food: food ?? this.food,
      wood: wood ?? this.wood,
      fish: fish ?? this.fish,
      flour: flour ?? this.flour,
      plank: plank ?? this.plank,
      bread: bread ?? this.bread,
      furniture: furniture ?? this.furniture,
      stone: stone ?? this.stone,
      iron: iron ?? this.iron,
      obsidian: obsidian ?? this.obsidian,
      mithril: mithril ?? this.mithril,
      crowns: crowns ?? this.crowns,
      tamgas: tamgas ?? this.tamgas,
    );
  }

  Map<String, dynamic> toJson() => {
        'food': food,
        'wood': wood,
        'fish': fish,
        'flour': flour,
        'plank': plank,
        'bread': bread,
        'furniture': furniture,
        'stone': stone,
        'iron': iron,
        'obsidian': obsidian,
        'mithril': mithril,
        'crowns': crowns,
        'tamgas': tamgas,
      };

  factory ResourcesModel.fromJson(Map<String, dynamic> json) {
    return ResourcesModel(
      food: (json['food'] as num?)?.toDouble() ?? 0.0,
      wood: (json['wood'] as num?)?.toDouble() ?? 0.0,
      fish: (json['fish'] as num?)?.toDouble() ?? 0.0,
      flour: (json['flour'] as num?)?.toDouble() ?? 0.0,
      plank: (json['plank'] as num?)?.toDouble() ?? 0.0,
      bread: (json['bread'] as num?)?.toDouble() ?? 0.0,
      furniture: (json['furniture'] as num?)?.toDouble() ?? 0.0,
      stone: (json['stone'] as num?)?.toDouble() ?? 0.0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0.0,
      obsidian: (json['obsidian'] as num?)?.toDouble() ?? 0.0,
      mithril: (json['mithril'] as num?)?.toDouble() ?? 0.0,
      crowns: json['crowns'] as int? ?? 0,
      tamgas: json['tamgas'] as int? ?? 0,
    );
  }
}

class MigrationRecordModel {
  final int migrationNumber;
  final int ownedCount;
  final int tamgasGained;
  final int zudCount;
  final String topSynergy;
  final List<String> doctrinesUsed;
  final String timestamp;

  const MigrationRecordModel({
    required this.migrationNumber,
    required this.ownedCount,
    this.tamgasGained = 0,
    this.zudCount = 0,
    this.topSynergy = '',
    this.doctrinesUsed = const [],
    this.timestamp = '',
  });

  MigrationRecordModel copyWith({
    int? migrationNumber,
    int? ownedCount,
    int? tamgasGained,
    int? zudCount,
    String? topSynergy,
    List<String>? doctrinesUsed,
    String? timestamp,
  }) {
    return MigrationRecordModel(
      migrationNumber: migrationNumber ?? this.migrationNumber,
      ownedCount: ownedCount ?? this.ownedCount,
      tamgasGained: tamgasGained ?? this.tamgasGained,
      zudCount: zudCount ?? this.zudCount,
      topSynergy: topSynergy ?? this.topSynergy,
      doctrinesUsed: doctrinesUsed ?? this.doctrinesUsed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'migration_number': migrationNumber,
        'owned_count': ownedCount,
        'tamgas_gained': tamgasGained,
        'zud_count': zudCount,
        'top_synergy': topSynergy,
        'doctrines_used': doctrinesUsed,
        'timestamp': timestamp,
      };

  factory MigrationRecordModel.fromJson(Map<String, dynamic> json) {
    return MigrationRecordModel(
      migrationNumber: json['migration_number'] as int? ?? 1,
      ownedCount: json['owned_count'] as int? ?? 1,
      tamgasGained: json['tamgas_gained'] as int? ?? 0,
      zudCount: json['zud_count'] as int? ?? 0,
      topSynergy: json['top_synergy'] as String? ?? '',
      doctrinesUsed: (json['doctrines_used'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class ProgressionModel {
  final int castleLevel;
  final int ownedCount;
  final int purchasedMeadowCount;
  final int purchasedForestCount;
  final int purchasedSeaCount;
  final int purchasedMountainCount;
  final int totalMigrations;
  final int tutorialStep; // 0: Start, 1: Select Tile, 2: Conquer, 3: Build Corn, 4: Build Worker, 5: Collect, 6: Wood Tutorial...
  final List<MigrationRecordModel> migrationHistory;
  final Map<String, int> cumulativeBiomeCounts;
  final int totalSessions;

  const ProgressionModel({
    this.castleLevel = 1,
    this.ownedCount = 1,
    this.purchasedMeadowCount = 0,
    this.purchasedForestCount = 0,
    this.purchasedSeaCount = 0,
    this.purchasedMountainCount = 0,
    this.totalMigrations = 0,
    this.tutorialStep = 0,
    this.migrationHistory = const [],
    this.cumulativeBiomeCounts = const {},
    this.totalSessions = 1,
  });

  ProgressionModel copyWith({
    int? castleLevel,
    int? ownedCount,
    int? purchasedMeadowCount,
    int? purchasedForestCount,
    int? purchasedSeaCount,
    int? purchasedMountainCount,
    int? totalMigrations,
    int? tutorialStep,
    List<MigrationRecordModel>? migrationHistory,
    Map<String, int>? cumulativeBiomeCounts,
    int? totalSessions,
  }) {
    return ProgressionModel(
      castleLevel: castleLevel ?? this.castleLevel,
      ownedCount: ownedCount ?? this.ownedCount,
      purchasedMeadowCount: purchasedMeadowCount ?? this.purchasedMeadowCount,
      purchasedForestCount: purchasedForestCount ?? this.purchasedForestCount,
      purchasedSeaCount: purchasedSeaCount ?? this.purchasedSeaCount,
      purchasedMountainCount:
          purchasedMountainCount ?? this.purchasedMountainCount,
      totalMigrations: totalMigrations ?? this.totalMigrations,
      tutorialStep: tutorialStep ?? this.tutorialStep,
      migrationHistory: migrationHistory ?? this.migrationHistory,
      cumulativeBiomeCounts:
          cumulativeBiomeCounts ?? this.cumulativeBiomeCounts,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  Map<String, dynamic> toJson() => {
        'castle_level': castleLevel,
        'owned_count': ownedCount,
        'purchased_meadow_count': purchasedMeadowCount,
        'purchased_forest_count': purchasedForestCount,
        'purchased_sea_count': purchasedSeaCount,
        'purchased_mountain_count': purchasedMountainCount,
        'total_migrations': totalMigrations,
        'tutorial_step': tutorialStep,
        'migration_history': migrationHistory.map((m) => m.toJson()).toList(),
        'cumulative_biome_counts': cumulativeBiomeCounts,
        'total_sessions': totalSessions,
      };

  factory ProgressionModel.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['migration_history'] as List?;
    final List<MigrationRecordModel> history = [];
    if (rawHistory != null) {
      for (final item in rawHistory) {
        if (item is Map) {
          try {
            history.add(MigrationRecordModel.fromJson(
                Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
    }

    final rawBiomes = json['cumulative_biome_counts'] as Map?;
    final Map<String, int> biomeCounts = {};
    if (rawBiomes != null) {
      rawBiomes.forEach((k, v) {
        biomeCounts[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    return ProgressionModel(
      castleLevel: json['castle_level'] as int? ?? 1,
      ownedCount: json['owned_count'] as int? ?? 1,
      purchasedMeadowCount: json['purchased_meadow_count'] as int? ?? 0,
      purchasedForestCount: json['purchased_forest_count'] as int? ?? 0,
      purchasedSeaCount: json['purchased_sea_count'] as int? ?? 0,
      purchasedMountainCount: json['purchased_mountain_count'] as int? ?? 0,
      totalMigrations: json['total_migrations'] as int? ?? 0,
      tutorialStep: json['tutorial_step'] as int? ?? 0,
      migrationHistory: history,
      cumulativeBiomeCounts: biomeCounts,
      totalSessions: json['total_sessions'] as int? ?? 1,
    );
  }
}

class SeasonModel {
  final String current;
  final double timer;
  final int year;
  final bool isZud;

  const SeasonModel({
    this.current = 'SPRING',
    this.timer = 0.0,
    this.year = 1,
    this.isZud = false,
  });

  SeasonModel copyWith({
    String? current,
    double? timer,
    int? year,
    bool? isZud,
  }) {
    return SeasonModel(
      current: current ?? this.current,
      timer: timer ?? this.timer,
      year: year ?? this.year,
      isZud: isZud ?? this.isZud,
    );
  }

  Map<String, dynamic> toJson() => {
        'current': current,
        'timer': timer,
        'year': year,
        'is_zud': isZud,
      };

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      current: json['current'] as String? ?? 'SPRING',
      timer: (json['timer'] as num?)?.toDouble() ?? 0.0,
      year: json['year'] as int? ?? 1,
      isZud: json['is_zud'] as bool? ?? false,
    );
  }
}

class NotificationSettingsModel {
  final bool storageFullAlert;
  final bool seasonChangeAlert;
  final bool questCompletedAlert;
  final bool castleUpgradeReadyAlert;

  const NotificationSettingsModel({
    this.storageFullAlert = false,
    this.seasonChangeAlert = false,
    this.questCompletedAlert = false,
    this.castleUpgradeReadyAlert = false,
  });

  NotificationSettingsModel copyWith({
    bool? storageFullAlert,
    bool? seasonChangeAlert,
    bool? questCompletedAlert,
    bool? castleUpgradeReadyAlert,
  }) {
    return NotificationSettingsModel(
      storageFullAlert: storageFullAlert ?? this.storageFullAlert,
      seasonChangeAlert: seasonChangeAlert ?? this.seasonChangeAlert,
      questCompletedAlert: questCompletedAlert ?? this.questCompletedAlert,
      castleUpgradeReadyAlert:
          castleUpgradeReadyAlert ?? this.castleUpgradeReadyAlert,
    );
  }

  Map<String, dynamic> toJson() => {
        'storage_full_alert': storageFullAlert,
        'season_change_alert': seasonChangeAlert,
        'quest_completed_alert': questCompletedAlert,
        'castle_upgrade_ready_alert': castleUpgradeReadyAlert,
      };

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      storageFullAlert: json['storage_full_alert'] as bool? ?? false,
      seasonChangeAlert: json['season_change_alert'] as bool? ?? false,
      questCompletedAlert: json['quest_completed_alert'] as bool? ?? false,
      castleUpgradeReadyAlert:
          json['castle_upgrade_ready_alert'] as bool? ?? false,
    );
  }
}

class SettingsModel {
  final String language;
  final double sfxVolume;
  final bool sfxMuted;
  final NotificationSettingsModel notifications;
  final String activeThemePalette;
  final String activeTitle;

  const SettingsModel({
    this.language = 'tr',
    this.sfxVolume = 0.8,
    this.sfxMuted = false,
    this.notifications = const NotificationSettingsModel(),
    this.activeThemePalette = 'basalt',
    this.activeTitle = 'nomad',
  });

  SettingsModel copyWith({
    String? language,
    double? sfxVolume,
    bool? sfxMuted,
    NotificationSettingsModel? notifications,
    String? activeThemePalette,
    String? activeTitle,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      sfxMuted: sfxMuted ?? this.sfxMuted,
      notifications: notifications ?? this.notifications,
      activeThemePalette: activeThemePalette ?? this.activeThemePalette,
      activeTitle: activeTitle ?? this.activeTitle,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'sfx_volume': sfxVolume,
        'sfx_muted': sfxMuted,
        'notifications': notifications.toJson(),
        'active_theme_palette': activeThemePalette,
        'active_title': activeTitle,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final rawNotif = json['notifications'] as Map?;
    final notif = rawNotif != null
        ? NotificationSettingsModel.fromJson(
            Map<String, dynamic>.from(rawNotif))
        : const NotificationSettingsModel();

    return SettingsModel(
      language: json['language'] as String? ?? 'tr',
      sfxVolume: (json['sfx_volume'] as num?)?.toDouble() ?? 0.8,
      sfxMuted: json['sfx_muted'] as bool? ?? false,
      notifications: notif,
      activeThemePalette: json['active_theme_palette'] as String? ?? 'basalt',
      activeTitle: json['active_title'] as String? ?? 'nomad',
    );
  }
}
