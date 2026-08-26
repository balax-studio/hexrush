import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ancestral_kurgan_model.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/caravan_route_model.dart';
import 'package:hex_rush/domain/models/celestial_omen_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/services/symbiosis_engine.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('9 Yenilikçi Mekanik & Fonksiyon Testleri', () {
    test('1. Yaylak-Kışlak & Toprak Solunumu (Soil Respiration 2.5x Boost)', () {
      // Dinlenen ve 10 sn solunum biriktiren karo 2.5x çarpan almalı
      final tileWithRespiration = HexTileModel(
        coord: const HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        soilHealth: 0.5,
        isResting: false,
        restTimeAccumulated: 12.0,
      );
      final double restingBoost = EconomyCalculator.calculateSoilHealthMultiplier(tileWithRespiration);
      expect(restingBoost, equals(2.5));

      // Dinlenmekte olan karo üretim yapmaz (0.0x)
      final tileResting = HexTileModel(
        coord: const HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        soilHealth: 0.5,
        isResting: true,
        restTimeAccumulated: 5.0,
      );
      final double currentlyResting = EconomyCalculator.calculateSoilHealthMultiplier(tileResting);
      expect(currentlyResting, equals(0.0));

      // Yorgun toprak (%0 sağlık) %70 verim verir
      final tileExhausted = HexTileModel(
        coord: const HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        soilHealth: 0.0,
        isResting: false,
        restTimeAccumulated: 0.0,
      );
      final double exhaustedSoil = EconomyCalculator.calculateSoilHealthMultiplier(tileExhausted);
      expect(exhaustedSoil, closeTo(0.70, 0.001));

      // Taze toprak (%100 sağlık) %100 verim verir
      final tileFresh = HexTileModel(
        coord: const HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        soilHealth: 1.0,
        isResting: false,
        restTimeAccumulated: 0.0,
      );
      final double freshSoil = EconomyCalculator.calculateSoilHealthMultiplier(tileFresh);
      expect(freshSoil, closeTo(1.0, 0.001));
    });

    test('2. İpek Yolu Kervan Hatları (+%25 Takas Rezonansı)', () {
      final routes = [
        const CaravanRoute(
          id: 'route-1',
          startCoord: HexAxial(0, 0),
          endCoord: HexAxial(1, 0),
          synergyType: 'trade_resonance',
          bonusMultiplier: 1.25,
        ),
      ];

      // Kervan bağlı karo 1.25x çarpan alır
      final double connectedMult = EconomyCalculator.calculateCaravanRouteMultiplier(
        const HexAxial(0, 0),
        routes,
      );
      expect(connectedMult, equals(1.25));

      // Bağlı olmayan karo 1.0x alır
      final double unconnectedMult = EconomyCalculator.calculateCaravanRouteMultiplier(
        const HexAxial(5, 5),
        routes,
      );
      expect(unconnectedMult, equals(1.0));
    });

    test('3. Ekolojik Simbiyoz & Hibrit Biyom Dönüşümü (+%50 Bonus)', () {
      final center = HexTileModel(
        coord: const HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
      );

      final forest1 = HexTileModel(
        coord: const HexAxial(1, 0),
        biome: TileBiome.forest,
        state: TileState.owned,
      );

      final forest2 = HexTileModel(
        coord: const HexAxial(0, 1),
        biome: TileBiome.forest,
        state: TileState.owned,
      );

      final wetland = HexTileModel(
        coord: const HexAxial(-1, 0),
        biome: TileBiome.wetland,
        state: TileState.owned,
      );

      final allTiles = <HexAxial, HexTileModel>{
        center.coord: center,
        forest1.coord: forest1,
        forest2.coord: forest2,
        wetland.coord: wetland,
      };

      final symbiosis = SymbiosisEngine.evaluateSymbiosis(center.coord, allTiles);
      expect(symbiosis, equals(SymbiosisType.wildGlade));

      // Simbiyoz çarpanı +%50 (1.5x)
      final symbioticTile = center.copyWith(symbiosis: SymbiosisType.wildGlade);
      final double bonus = EconomyCalculator.calculateSymbiosisMultiplier(symbioticTile);
      expect(bonus, equals(1.5));
    });

    test('4. 12 Hayvanlı Göksel Alametler (12-Animal Celestial Omens)', () {
      // Sıçan yılı -> Ekmek ve Gıda +%40 (1.40x)
      final ratOmen = CelestialOmen.fromYearIndex(0);
      expect(ratOmen.animal, equals(CelestialAnimal.rat));
      expect(EconomyCalculator.calculateCelestialOmenMultiplier(ratOmen, resourceType: 'food'), equals(1.40));

      // Pars yılı -> Kereste ve Kalas 2.0x
      final tigerOmen = CelestialOmen.fromYearIndex(2);
      expect(tigerOmen.animal, equals(CelestialAnimal.tiger));
      expect(EconomyCalculator.calculateCelestialOmenMultiplier(tigerOmen, resourceType: 'wood'), equals(2.0));

      // At yılı -> Hız ve Hareket bonusu
      final horseOmen = CelestialOmen.fromYearIndex(6);
      expect(horseOmen.animal, equals(CelestialAnimal.horse));
    });

    test('5. Ata Kurganı Kalıntıları & Kalıcı Miras (+%35 Çarpan)', () {
      final discoveredKurgans = [
        const AncestralKurgan(
          id: 'kurgan-1',
          coord: HexAxial(0, 1),
          formerLevel: 3,
          formerBuildingType: BuildingType.sawmill,
          relicTitle: 'Kadim Hızarhane Kurganı',
          bonusMultiplier: 0.35,
          isDiscovered: true,
        ),
      ];

      // Keşfedilmiş kurgan ile toplam kalıcı miras çarpanı 1.35x olur
      final double relicBonus = EconomyCalculator.calculateAncestralRelicMultiplier(discoveredKurgans);
      expect(relicBonus, equals(1.35));

      // Keşfedilmemiş kurgan bonus vermez (1.0x)
      final undiscovered = [
        const AncestralKurgan(
          id: 'kurgan-2',
          coord: HexAxial(0, 2),
          formerLevel: 1,
          formerBuildingType: BuildingType.sawmill,
          relicTitle: 'Bilinmeyen Kurgan',
          bonusMultiplier: 0.35,
          isDiscovered: false,
        ),
      ];
      final double noBonus = EconomyCalculator.calculateAncestralRelicMultiplier(undiscovered);
      expect(noBonus, equals(1.0));
    });

    test('6. Dokunsal Ritim Ahenk Bonusu (1.0x -> 3.0x Kombo)', () {
      // 0 kombo -> 1.0x
      expect(EconomyCalculator.calculateRhythmComboMultiplier(0), equals(1.0));

      // 5 kombo -> 3.0x (1.0 + 5 * 0.4 = 3.0)
      expect(EconomyCalculator.calculateRhythmComboMultiplier(5), equals(3.0));
    });

    test('7. Kuş Bakışı Mercek & Diorama Modu State Değişimleri', () {
      final notifier = GameStateNotifier();

      expect(notifier.state.isMacroOverview, isFalse);
      expect(notifier.state.isDioramaMode, isFalse);

      notifier.toggleMacroOverview();
      expect(notifier.state.isMacroOverview, isTrue);

      notifier.toggleDioramaMode();
      expect(notifier.state.isDioramaMode, isTrue);
    });

    test('8. GameStateNotifier Kervan Hattı & Yaylak Göç Eylemleri', () {
      final notifier = GameStateNotifier();
      
      // Kaynakları ve Kağan Otağını ayarla
      final currentTiles = Map<HexAxial, HexTileModel>.from(notifier.state.tiles);
      currentTiles[const HexAxial(0, 0)] = const HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
      );
      currentTiles[const HexAxial(1, 0)] = const HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
      );

      notifier.state = notifier.state.copyWith(
        tiles: currentTiles,
        resources: notifier.state.resources.copyWith(
          food: 500,
          plank: 100,
          bread: 100,
        ),
        progression: notifier.state.progression.copyWith(castleLevel: 5),
      );

      // Kervan kur
      notifier.addCaravanRoute(const HexAxial(0, 0), const HexAxial(1, 0));
      expect(notifier.state.caravanRoutes.length, equals(1));
      expect(notifier.state.caravanRoutes.first.startCoord, equals(const HexAxial(0, 0)));
      expect(notifier.state.caravanRoutes.first.endCoord, equals(const HexAxial(1, 0)));

      // Yaylak-kışlak dinlendirme aç
      notifier.toggleTranshumance();
      expect(notifier.state.tiles[const HexAxial(0, 0)]!.isResting, isTrue);
    });
  });
}
