import '../models/achievement_model.dart';
import '../models/building_model.dart';
import '../models/game_state.dart';
import '../models/hex_tile_model.dart';

class AchievementTrackerResult {
  final List<AchievementModel> updatedAchievements;
  final List<AchievementModel> newlyUnlocked;

  const AchievementTrackerResult({
    required this.updatedAchievements,
    required this.newlyUnlocked,
  });
}

class AchievementTracker {
  /// Oyun durumuna göre başarımların ilerleme ve kilit açılma durumlarını hesaplar
  static AchievementTrackerResult evaluate(GameState state) {
    final currentList = state.achievements.isNotEmpty
        ? state.achievements
        : AchievementCatalog.getInitialList();

    final List<AchievementModel> updated = [];
    final List<AchievementModel> newlyUnlocked = [];
    final nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final ownedTiles = state.tiles.values.where((t) => t.isOwned).toList();
    final ownedCount = ownedTiles.length;

    // Kıyı/Su kenarı karoları
    final waterEdgeCount = ownedTiles.where((t) =>
        t.biome == TileBiome.sea ||
        t.biome == TileBiome.wetland).length;

    // Dağ karoları
    final hasMountain = ownedTiles.any((t) =>
        t.biome == TileBiome.mountain ||
        t.building?.type == BuildingType.mine ||
        t.building?.type == BuildingType.quarry);

    // Tier 3 sayımları
    final hasT3Lumberjack = ownedTiles.any((t) =>
        (t.building?.type == BuildingType.lumberjack ||
            t.building?.type == BuildingType.sawmill) &&
        (t.building?.level ?? 0) >= 3);

    final hasT3FarmOrMill = ownedTiles.any((t) =>
        (t.building?.type == BuildingType.corn ||
            t.building?.type == BuildingType.barley ||
            t.building?.type == BuildingType.pasture ||
            t.building?.type == BuildingType.windmill ||
            t.building?.type == BuildingType.bakery) &&
        (t.building?.level ?? 0) >= 3);

    final hasT3Mine = ownedTiles.any((t) =>
        (t.building?.type == BuildingType.mine ||
            t.building?.type == BuildingType.obsidianForge) &&
        (t.building?.level ?? 0) >= 3);

    final hasT3Castle = ownedTiles.any((t) =>
        t.building?.type == BuildingType.castle && (t.building?.level ?? 1) >= 3);

    final totalT3Buildings = ownedTiles.where((t) =>
        t.building?.type != BuildingType.castle && (t.building?.level ?? 0) >= 3).length;

    // Kış ve ısıtma kontrolü
    final allHeatedInWinter = ownedTiles.isNotEmpty &&
        ownedTiles.where((t) => t.building != null).every((t) => t.isWarmed || t.warmTimer > 0);

    // Büyük göç ve tamgalar
    final migrations = state.progression.totalMigrations;
    final hasTamgas = state.resources.tamgas > 0;
    final hasActiveDoctrine = state.activeDoctrineSlots.values.any((d) => d != null && d.isNotEmpty);

    // Pazar ve takas istatistiği
    final marketTraded = (state.stats['market_total_traded'] as num?)?.toDouble() ?? 0.0;
    final demolishedCount = (state.stats['buildings_demolished'] as num?)?.toDouble() ?? 0.0;

    for (final ach in currentList) {
      double current = ach.currentProgress;
      bool unlock = ach.isUnlocked;

      switch (ach.id) {
        // --- CONQUEST ---
        case 'ach_first_conquest':
          current = ownedCount.toDouble();
          if (ownedCount >= 1) unlock = true;
          break;
        case 'ach_steppe_borders':
          current = ownedCount.toDouble();
          if (ownedCount >= 10) unlock = true;
          break;
        case 'ach_great_domain':
          current = ownedCount.toDouble();
          if (ownedCount >= 25) unlock = true;
          break;
        case 'ach_boundless':
          current = ownedCount.toDouble();
          if (ownedCount >= 50) unlock = true;
          break;
        case 'ach_water_lord':
          current = waterEdgeCount.toDouble();
          if (waterEdgeCount >= 5) unlock = true;
          break;
        case 'ach_mountain_pass':
          current = hasMountain ? 1.0 : 0.0;
          if (hasMountain) unlock = true;
          break;

        // --- INDUSTRY ---
        case 'ach_master_lumberjack':
          current = hasT3Lumberjack ? 1.0 : 0.0;
          if (hasT3Lumberjack) unlock = true;
          break;
        case 'ach_golden_wheat':
          current = hasT3FarmOrMill ? 1.0 : 0.0;
          if (hasT3FarmOrMill) unlock = true;
          break;
        case 'ach_deep_mine':
          current = hasT3Mine ? 1.0 : 0.0;
          if (hasT3Mine) unlock = true;
          break;
        case 'ach_grand_palace':
          current = hasT3Castle ? 1.0 : 0.0;
          if (hasT3Castle) unlock = true;
          break;
        case 'ach_full_automation':
          current = totalT3Buildings.toDouble();
          if (totalT3Buildings >= 3) unlock = true;
          break;
        case 'ach_iron_surge':
          final ironVal = state.resources.iron;
          current = ironVal;
          if (ironVal >= 30) unlock = true;
          break;

        // --- WINTER ---
        case 'ach_first_winter':
          current = state.yearIndex.toDouble();
          if (state.yearIndex >= 1) unlock = true;
          break;
        case 'ach_warm_hearth':
          if (state.season.current == 'WINTER' && allHeatedInWinter) {
            current = 1.0;
            unlock = true;
          }
          break;
        case 'ach_winter_prep':
          if (state.season.current == 'WINTER' && state.resources.wood >= 500) {
            current = 500.0;
            unlock = true;
          }
          break;
        case 'ach_four_seasons':
          current = state.yearIndex.toDouble();
          if (state.yearIndex >= 4) unlock = true;
          break;

        // --- PRESTIGE ---
        case 'ach_first_migration':
          current = migrations.toDouble();
          if (migrations >= 1) unlock = true;
          break;
        case 'ach_ancestral_seal':
          current = hasTamgas ? 1.0 : 0.0;
          if (hasTamgas) unlock = true;
          break;
        case 'ach_council_assembly':
          current = hasActiveDoctrine ? 1.0 : 0.0;
          if (hasActiveDoctrine) unlock = true;
          break;
        case 'ach_steppe_legend':
          current = migrations.toDouble();
          if (migrations >= 3) unlock = true;
          break;

        // --- TRADE ---
        case 'ach_silk_road_traveler':
          final caravanCount = state.caravanRoutes.length;
          current = caravanCount.toDouble();
          if (caravanCount >= 1) unlock = true;
          break;
        case 'ach_market_guild':
          current = marketTraded;
          if (marketTraded >= 500) unlock = true;
          break;
        case 'ach_crown_hoard':
          current = state.resources.crowns.toDouble();
          if (state.resources.crowns >= 100) unlock = true;
          break;

        // --- MASTERY ---
        case 'ach_frenzy_peak':
          if (state.frenzyTimer > 0 || state.frenzyMultiplier > 1) {
            current = 1.0;
            unlock = true;
          }
          break;
        case 'ach_remodel_master':
          current = demolishedCount;
          if (demolishedCount >= 1) unlock = true;
          break;
        case 'ach_rhythm_master':
          current = state.rhythmCombo.toDouble();
          if (state.rhythmCombo >= 10) unlock = true;
          break;
      }

      final isNowUnlocked = unlock && !ach.isUnlocked;
      final updatedAch = ach.copyWith(
        currentProgress: current > ach.targetProgress ? ach.targetProgress : current,
        isUnlocked: unlock,
        unlockedAt: isNowUnlocked ? nowTimestamp : ach.unlockedAt,
      );

      if (isNowUnlocked) {
        newlyUnlocked.add(updatedAch);
      }

      updated.add(updatedAch);
    }

    return AchievementTrackerResult(
      updatedAchievements: updated,
      newlyUnlocked: newlyUnlocked,
    );
  }
}
