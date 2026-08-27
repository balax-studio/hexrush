import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  group('Özel Biyomlar ve Binalar Test Paketi', () {
    test('13 Yeni Bina için Castle Level Kilitleri ve Temel Veriler Doğru Olmalıdır', () {
      // Level 2 Binalar
      expect(BuildingType.oasisCistern.requiredCastleLevel, 2);
      expect(BuildingType.herbalistYurt.requiredCastleLevel, 2);

      // Level 12 Binalar (Eski Level 3)
      expect(BuildingType.caravanserai.requiredCastleLevel, 12);
      expect(BuildingType.reindeerSanctuary.requiredCastleLevel, 12);
      expect(BuildingType.scribeWorkshop.requiredCastleLevel, 12);

      // Level 22 Binalar (Eski Level 4)
      expect(BuildingType.astrolabe.requiredCastleLevel, 22);
      expect(BuildingType.geothermalBath.requiredCastleLevel, 22);
      expect(BuildingType.permafrostDig.requiredCastleLevel, 22);
      expect(BuildingType.steamVent.requiredCastleLevel, 22);

      // Level 32 Efsanevi Binalar (Eski Level 5)
      expect(BuildingType.obsidianForge.requiredCastleLevel, 32);
      expect(BuildingType.celestialAnvil.requiredCastleLevel, 32);
      expect(BuildingType.ancestralTotem.requiredCastleLevel, 32);
      expect(BuildingType.prismaticResonator.requiredCastleLevel, 32);
    });

    test('Biyomlara Özgü İzin Verilen Binalar Doğru Eşleşmelidir', () {
      // Çöl
      final desertBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.desert);
      expect(desertBuildings.contains(BuildingType.oasisCistern), isTrue);
      expect(desertBuildings.contains(BuildingType.caravanserai), isTrue);
      expect(desertBuildings.contains(BuildingType.astrolabe), isTrue);

      // Tundra
      final tundraBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.tundra);
      expect(tundraBuildings.contains(BuildingType.reindeerSanctuary), isTrue);
      expect(tundraBuildings.contains(BuildingType.geothermalBath), isTrue);
      expect(tundraBuildings.contains(BuildingType.permafrostDig), isTrue);

      // Volkan
      final volcanoBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.volcano);
      expect(volcanoBuildings.contains(BuildingType.steamVent), isTrue);
      expect(volcanoBuildings.contains(BuildingType.obsidianForge), isTrue);

      // Sazlık
      final wetlandBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.wetland);
      expect(wetlandBuildings.contains(BuildingType.herbalistYurt), isTrue);
      expect(wetlandBuildings.contains(BuildingType.scribeWorkshop), isTrue);

      // Efsanevi Biyomlar
      final craterBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.celestialCrater);
      expect(craterBuildings.contains(BuildingType.celestialAnvil), isTrue);

      final kurganBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.kurganValley);
      expect(kurganBuildings.contains(BuildingType.ancestralTotem), isTrue);

      final chasmBuildings = GameStateNotifier.getAllowedBuildingsForBiome(TileBiome.crystalChasm);
      expect(chasmBuildings.contains(BuildingType.prismaticResonator), isTrue);
    });

    test('Harita Üretimi 3 Efsanevi Biyomu İçermelidir', () {
      final notifier = GameStateNotifier();
      final map = notifier.state.tiles;
      
      final bool hasCrater = map.values.any((t) => t.biome == TileBiome.celestialCrater);
      final bool hasKurgan = map.values.any((t) => t.biome == TileBiome.kurganValley);
      final bool hasChasm = map.values.any((t) => t.biome == TileBiome.crystalChasm);

      expect(hasCrater, isTrue);
      expect(hasKurgan, isTrue);
      expect(hasChasm, isTrue);

      // Merkez kale (0,0) çayır olmalıdır
      expect(map[const HexAxial(0, 0)]?.biome, TileBiome.meadow);
      expect(map[const HexAxial(0, 0)]?.building?.type, BuildingType.castle);
      notifier.dispose();
    });

    test('Efsanevi ve Özel Biyom Sinerjileri Doğru Hesaplanmalıdır', () {
      const center = HexAxial(2, 2);
      const tile = HexTileModel(
        coord: center,
        biome: TileBiome.celestialCrater,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.celestialAnvil, level: 1),
      );

      final synergy = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: tile,
        neighborTiles: [],
        season: 'SPRING',
        isZud: false,
      );

      // Göksel Krater sinerjisi +%50 (1.50)
      expect(synergy, closeTo(1.50, 0.001));

      final labels = EconomyCalculator.getActiveSynergyLabels(
        targetTile: tile,
        neighborTiles: [],
        season: 'SPRING',
        isZud: false,
      );
      expect(labels.any((l) => l.contains('GÖKSEL CEVHER')), isTrue);
    });

    test('Vaha Sarnıcı Komşulara +%40 Bereket Aurası Vermelidir', () {
      const center = HexAxial(3, 3);
      final farmCoord = center.neighbors.first;

      const cisternTile = HexTileModel(
        coord: center,
        biome: TileBiome.desert,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.oasisCistern, level: 1),
      );

      final farmTile = HexTileModel(
        coord: farmCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(type: BuildingType.corn, level: 1),
      );

      final synergy = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: farmTile,
        neighborTiles: [cisternTile],
        season: 'SUMMER',
        isZud: false,
      );

      // Çöl vaha sarnıcı aurası +%40 (1.40) ve yaz kuraklığını iptal eder
      expect(synergy >= 1.40, isTrue);
    });

    test('Bina ve Biyom Serileştirme Hatasız Çalışmalıdır', () {
      for (final type in BuildingType.values) {
        final serialized = type.name;
        final deserialized = BuildingType.values.byName(serialized);
        expect(deserialized, type);
      }

      for (final biome in TileBiome.values) {
        final serialized = biome.name;
        final deserialized = TileBiome.values.byName(serialized);
        expect(deserialized, biome);
      }
    });
  });
}
