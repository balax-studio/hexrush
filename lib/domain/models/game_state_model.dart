class ResourcesModel {
  final double food;
  final double wood;
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

class ProgressionModel {
  final int castleLevel;
  final int ownedCount;
  final int purchasedMeadowCount;
  final int purchasedForestCount;
  final int purchasedSeaCount;
  final int purchasedMountainCount;
  final int totalMigrations;

  const ProgressionModel({
    this.castleLevel = 1,
    this.ownedCount = 1,
    this.purchasedMeadowCount = 0,
    this.purchasedForestCount = 0,
    this.purchasedSeaCount = 0,
    this.purchasedMountainCount = 0,
    this.totalMigrations = 0,
  });

  ProgressionModel copyWith({
    int? castleLevel,
    int? ownedCount,
    int? purchasedMeadowCount,
    int? purchasedForestCount,
    int? purchasedSeaCount,
    int? purchasedMountainCount,
    int? totalMigrations,
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
      };

  factory ProgressionModel.fromJson(Map<String, dynamic> json) {
    return ProgressionModel(
      castleLevel: json['castle_level'] as int? ?? 1,
      ownedCount: json['owned_count'] as int? ?? 1,
      purchasedMeadowCount: json['purchased_meadow_count'] as int? ?? 0,
      purchasedForestCount: json['purchased_forest_count'] as int? ?? 0,
      purchasedSeaCount: json['purchased_sea_count'] as int? ?? 0,
      purchasedMountainCount: json['purchased_mountain_count'] as int? ?? 0,
      totalMigrations: json['total_migrations'] as int? ?? 0,
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

class SettingsModel {
  final String language;
  final double sfxVolume;
  final bool sfxMuted;

  const SettingsModel({
    this.language = 'tr',
    this.sfxVolume = 0.8,
    this.sfxMuted = false,
  });

  SettingsModel copyWith({
    String? language,
    double? sfxVolume,
    bool? sfxMuted,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      sfxMuted: sfxMuted ?? this.sfxMuted,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'sfx_volume': sfxVolume,
        'sfx_muted': sfxMuted,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      language: json['language'] as String? ?? 'tr',
      sfxVolume: (json['sfx_volume'] as num?)?.toDouble() ?? 0.8,
      sfxMuted: json['sfx_muted'] as bool? ?? false,
    );
  }
}
