import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/localization/game_localization.dart';
import 'package:hex_rush/domain/models/building_model.dart';

void main() {
  group('Building Localization & Description Tests', () {
    const languages = ['tr', 'en', 'es', 'de'];

    test('All 37 BuildingType values have valid names in all 4 languages', () {
      for (final type in BuildingType.values) {
        for (final lang in languages) {
          final String key = type == BuildingType.castle ? 'castle_title' : _getExpectedNameKey(type);
          final String name = GameLocalization.get(key, lang: lang);
          expect(
            name.isNotEmpty,
            isTrue,
            reason: 'Building $type should have a non-empty name in $lang',
          );
          expect(
            name,
            isNot(equals(key)),
            reason: 'Building $type name should be localized in $lang, not return the key',
          );
        }
      }
    });

    test('All 37 BuildingType values have valid descriptions in all 4 languages', () {
      for (final type in BuildingType.values) {
        for (final lang in languages) {
          final String key = type == BuildingType.castle ? 'castle_desc' : _getExpectedDescKey(type);
          final String desc = GameLocalization.get(key, lang: lang);
          expect(
            desc.isNotEmpty,
            isTrue,
            reason: 'Building $type should have a non-empty description in $lang',
          );
          expect(
            desc,
            isNot(equals(key)),
            reason: 'Building $type description should be localized in $lang, not return the key',
          );
        }
      }
    });
  });
}

String _getExpectedNameKey(BuildingType type) {
  switch (type) {
    case BuildingType.castle:
      return 'castle_title';
    case BuildingType.corn:
      return 'corn_name';
    case BuildingType.barley:
      return 'barley_name';
    case BuildingType.pasture:
      return 'pasture_name';
    case BuildingType.orchard:
      return 'orchard_name';
    case BuildingType.quarry:
      return 'quarry_name';
    case BuildingType.resinCamp:
      return 'resin_camp_name';
    case BuildingType.lumberjack:
      return 'lumberjack_name';
    case BuildingType.windmill:
      return 'windmill_name';
    case BuildingType.sawmill:
      return 'sawmill_name';
    case BuildingType.bakery:
      return 'bakery_name';
    case BuildingType.furniture:
      return 'furniture_name';
    case BuildingType.worker:
      return 'worker_name';
    case BuildingType.watchtower:
      return 'watchtower_name';
    case BuildingType.mine:
      return 'mine_name';
    case BuildingType.bridge:
      return 'bridge_name';
    case BuildingType.fisherman:
      return 'fisherman_name';
    case BuildingType.fishermanHut:
      return 'fisherman_hut_name';
    case BuildingType.oasisCistern:
      return 'oasis_cistern_name';
    case BuildingType.caravanserai:
      return 'caravanserai_name';
    case BuildingType.astrolabe:
      return 'astrolabe_name';
    case BuildingType.reindeerSanctuary:
      return 'reindeer_sanctuary_name';
    case BuildingType.geothermalBath:
      return 'geothermal_bath_name';
    case BuildingType.permafrostDig:
      return 'permafrost_dig_name';
    case BuildingType.steamVent:
      return 'steam_vent_name';
    case BuildingType.obsidianForge:
      return 'obsidian_forge_name';
    case BuildingType.herbalistYurt:
      return 'herbalist_yurt_name';
    case BuildingType.scribeWorkshop:
      return 'scribe_workshop_name';
    case BuildingType.celestialAnvil:
      return 'celestial_anvil_name';
    case BuildingType.ancestralTotem:
      return 'ancestral_totem_name';
    case BuildingType.prismaticResonator:
      return 'prismatic_resonator_name';
    case BuildingType.granaryVault:
      return 'granary_vault_name';
    case BuildingType.kumisYurt:
      return 'kumis_yurt_name';
    case BuildingType.feltTentWorkshop:
      return 'felt_tent_workshop_name';
    case BuildingType.damascusForge:
      return 'damascus_forge_name';
    case BuildingType.runicStele:
      return 'runic_stele_name';
  }
}

String _getExpectedDescKey(BuildingType type) {
  switch (type) {
    case BuildingType.castle:
      return 'castle_desc';
    case BuildingType.corn:
      return 'corn_desc';
    case BuildingType.barley:
      return 'barley_desc';
    case BuildingType.pasture:
      return 'pasture_desc';
    case BuildingType.orchard:
      return 'orchard_desc';
    case BuildingType.quarry:
      return 'quarry_desc';
    case BuildingType.resinCamp:
      return 'resin_camp_desc';
    case BuildingType.lumberjack:
      return 'lumberjack_desc';
    case BuildingType.windmill:
      return 'windmill_desc';
    case BuildingType.sawmill:
      return 'sawmill_desc';
    case BuildingType.bakery:
      return 'bakery_desc';
    case BuildingType.furniture:
      return 'furniture_desc';
    case BuildingType.worker:
      return 'worker_desc';
    case BuildingType.watchtower:
      return 'watchtower_desc';
    case BuildingType.mine:
      return 'mine_desc';
    case BuildingType.bridge:
      return 'bridge_desc';
    case BuildingType.fisherman:
      return 'fisherman_desc';
    case BuildingType.fishermanHut:
      return 'fisherman_hut_desc';
    case BuildingType.oasisCistern:
      return 'oasis_cistern_desc';
    case BuildingType.caravanserai:
      return 'caravanserai_desc';
    case BuildingType.astrolabe:
      return 'astrolabe_desc';
    case BuildingType.reindeerSanctuary:
      return 'reindeer_sanctuary_desc';
    case BuildingType.geothermalBath:
      return 'geothermal_bath_desc';
    case BuildingType.permafrostDig:
      return 'permafrost_dig_desc';
    case BuildingType.steamVent:
      return 'steam_vent_desc';
    case BuildingType.obsidianForge:
      return 'obsidian_forge_desc';
    case BuildingType.herbalistYurt:
      return 'herbalist_yurt_desc';
    case BuildingType.scribeWorkshop:
      return 'scribe_workshop_desc';
    case BuildingType.celestialAnvil:
      return 'celestial_anvil_desc';
    case BuildingType.ancestralTotem:
      return 'ancestral_totem_desc';
    case BuildingType.prismaticResonator:
      return 'prismatic_resonator_desc';
    case BuildingType.granaryVault:
      return 'granary_vault_desc';
    case BuildingType.kumisYurt:
      return 'kumis_yurt_desc';
    case BuildingType.feltTentWorkshop:
      return 'felt_tent_workshop_desc';
    case BuildingType.damascusForge:
      return 'damascus_forge_desc';
    case BuildingType.runicStele:
      return 'runic_stele_desc';
  }
}
