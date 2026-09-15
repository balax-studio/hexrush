import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/icons/game_vector_icons.dart';
import 'package:hex_rush/presentation/widgets/left_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Sol Bar & Vektörel İkon Doğrulama', () {
    testWidgets('LeftBar renders correctly with 8 vector buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LeftBar(
                onOpenStory: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LeftBar), findsOneWidget);
      expect(find.byType(GameVectorIcon), findsNWidgets(8));
    });

    testWidgets('All new GameVectorIcon types paint without exception', (tester) async {
      final types = [
        GameIconType.macroOverview,
        GameIconType.loreTree,
        GameIconType.tradeOrders,
        GameIconType.steppeHorn,
        GameIconType.realmMap,
        GameIconType.dioramaCamera,
        GameIconType.hexpedia,
        GameIconType.steppeStory,
      ];

      for (final type in types) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: GameVectorIcon(type: type, size: 24, color: Colors.amber),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('2. Arka Plan AFK Gelir Desteği & Lifecycle', () {
    test('calculateOfflineGains produces gains for >= 3 seconds threshold', () {
      const cornTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );
      const workerTile = HexTileModel(
        coord: HexAxial(1, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.worker, level: 1),
      );

      // 4 saniyelik arka plan süresi (> 3s)
      final gains = EconomyCalculator.calculateOfflineGains(
        tiles: [cornTile, workerTile],
        elapsedSeconds: 4.0,
        globalMultiplier: 1.0,
        minThresholdSeconds: 3.0,
      );

      expect(gains.hasGains, isTrue);
      expect(gains.food, greaterThan(0.0));
      expect(gains.seconds, equals(4));
    });

    test('pauseGameLoop and resumeGameLoop correctly triggers offline gains after > 3s', () async {
      final notifier = GameStateNotifier();
      final tiles = <HexAxial, HexTileModel>{
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexAxial(1, 0): const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
      };

      notifier.state = notifier.state.copyWith(tiles: tiles);

      // Simüle edilen pause zamanı: 10 saniye önce
      final int pastTimestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 10;
      notifier.processResumeOfflineGains(pastTimestamp);

      expect(notifier.state.pendingOfflineGains, isNotNull);
      expect(notifier.state.pendingOfflineGains!.hasGains, isTrue);
      expect(notifier.state.pendingOfflineGains!.seconds, greaterThanOrEqualTo(9));
    });
  });

  group('3. İşçi Kulübesi Greedy Dağıtımı & Menzil Çakışması', () {
    test('Greedy allocation assigns production to closest worker and spills over when capacity is full', () {
      // Düzen:
      // Mısır Tarlası (0, 0): talep = 0.42/sn
      // İşçi Kulübesi 1 (1, 0): mesafe 1, kapasite 0.20/sn (yetmiyor)
      // İşçi Kulübesi 2 (3, 0): mesafe 3, kapasite 1.00/sn (kalanı alacak)
      const cornCoord = HexAxial(0, 0);
      const worker1Coord = HexAxial(1, 0);
      const worker2Coord = HexAxial(3, 0);

      final tiles = <HexAxial, HexTileModel>{
        cornCoord: const HexTileModel(
          coord: cornCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 5),
        ),
        worker1Coord: const HexTileModel(
          coord: worker1Coord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker, level: 1), // kapasite 0.2
        ),
        worker2Coord: const HexTileModel(
          coord: worker2Coord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker, level: 5), // yüksek kapasite
        ),
      };

      final allStats = EconomyCalculator.calculateAllWorkerLogisticsStats(tiles: tiles);

      expect(allStats.containsKey(worker1Coord), isTrue);
      expect(allStats.containsKey(worker2Coord), isTrue);

      final stats1 = allStats[worker1Coord]!;
      final stats2 = allStats[worker2Coord]!;

      // Kulübe 1 en yakın olduğu için tam kapasite dolmalıdır (%100)
      expect(stats1.utilizedCapacity, closeTo(stats1.totalCapacity, 0.01));
      expect(stats1.utilizationRatio, closeTo(1.0, 0.01));

      // Kulübe 2 kalanı aldığı için sahte %100 değil, gerçek kalan yük oranını yansıtmalıdır (< 1.0)
      expect(stats2.utilizedCapacity, greaterThan(0.0));
      expect(stats2.utilizationRatio, lessThan(1.0));
    });
  });

  group('5. Otomatik Isıtma (Auto-Heat) & Fail-Safe Rezerv Kontrolü', () {
    test('HexTileModel serializes and deserializes isAutoHeatEnabled', () {
      const tile = HexTileModel(
        coord: HexAxial(2, 3),
        biome: TileBiome.forest,
        state: TileState.owned,
        isAutoHeatEnabled: true,
      );

      final json = tile.toJson();
      expect(json['is_auto_heat_enabled'], isTrue);

      final fromJson = HexTileModel.fromJson(json);
      expect(fromJson.isAutoHeatEnabled, isTrue);
    });

    test('toggleAutoHeat flips the auto-heat status of the tile', () {
      final notifier = GameStateNotifier();
      const coord = HexAxial(0, 0);
      notifier.state = notifier.state.copyWith(
        tiles: {
          coord: const HexTileModel(
            coord: coord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            isAutoHeatEnabled: false,
          ),
        },
      );

      expect(notifier.state.tiles[coord]!.isAutoHeatEnabled, isFalse);

      notifier.toggleAutoHeat(coord);
      expect(notifier.state.tiles[coord]!.isAutoHeatEnabled, isTrue);

      notifier.toggleAutoHeat(coord);
      expect(notifier.state.tiles[coord]!.isAutoHeatEnabled, isFalse);
    });

    test('Auto-Heat warms tile in Winter when wood reserve is sufficient', () {
      final notifier = GameStateNotifier();
      const coord = HexAxial(1, 0);
      final tile = const HexTileModel(
        coord: coord,
        biome: TileBiome.forest,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.lumberjack, level: 1),
        isWarmed: false,
        warmTimer: 0.0,
        isAutoHeatEnabled: true,
      );

      notifier.state = notifier.state.copyWith(
        tiles: {coord: tile},
        season: notifier.state.season.copyWith(current: 'WINTER', isZud: false),
        resources: notifier.state.resources.copyWith(wood: 100.0), // Bol odun (> 2x maliyet)
      );

      notifier.testTick();

      final updatedTile = notifier.state.tiles[coord]!;
      expect(updatedTile.isWarmed, isTrue);
      expect(updatedTile.warmTimer, closeTo(179.0, 1.0)); // 180s - 1s tick
    });

    test('Auto-Heat fail-safe does NOT trigger when wood reserve is too low', () {
      final notifier = GameStateNotifier();
      const coord = HexAxial(1, 0);
      final tile = const HexTileModel(
        coord: coord,
        biome: TileBiome.forest,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.lumberjack, level: 1),
        isWarmed: false,
        warmTimer: 0.0,
        isAutoHeatEnabled: true,
      );

      // Yetersiz odun (< safeWoodReserve + warmWoodCost)
      notifier.state = notifier.state.copyWith(
        tiles: {coord: tile},
        season: notifier.state.season.copyWith(current: 'WINTER', isZud: false),
        resources: notifier.state.resources.copyWith(wood: 5.0),
      );

      notifier.testTick();

      final updatedTile = notifier.state.tiles[coord]!;
      // Odun rezervi yetmediği için otomatik ısıtıcı devreye girmemeli (Fail-safe)
      expect(updatedTile.isWarmed, isFalse);
      expect(updatedTile.warmTimer, equals(0.0));
      // Odun harcanmamalı
      expect(notifier.state.resources.wood, equals(5.0));
    });
  });

  group('6. İşçi 2X Taşıma Kapasitesi ve Taşınamayan Lojistik Darboğazı', () {
    test('Worker building has 2x carrying capacity (3.36 base)', () {
      const worker = BuildingModel(type: BuildingType.worker, level: 1);
      expect(worker.baseCarryingCapacity, closeTo(3.36, 0.01));
      expect(worker.currentCarryingCapacity, closeTo(3.36, 0.01));
    });

    test('calculateNetRates separates transported rate and untransported bottleneck rate', () {
      // Bir mısır tarlası (level 10 -> yüksek üretim) ve yetersiz taşıma kapasitesi
      const cornCoord = HexAxial(0, 0);
      final tiles = <HexAxial, HexTileModel>{
        cornCoord: const HexTileModel(
          coord: cornCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 10), // ~8.4/sn üretim
        ),
      };

      // İşçi yok, sadece şato taban 1.0/sn taşıma kapasitesi var (menzil içinde)
      final netRates = EconomyCalculator.calculateNetRates(
        tiles: tiles.values,
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
      );

      // Taşınan miktar şato kapasitesi (0.0 veya sınırlı), taşınamayan miktar ise > 0 olmalı
      expect(netRates.untransportedFood, greaterThan(0.0));
    });

    test('calculateResourceBreakdown computes totalUntransported and marks producer untransportedRate', () {
      const cornCoord = HexAxial(0, 0);
      final tiles = <HexAxial, HexTileModel>{
        cornCoord: const HexTileModel(
          coord: cornCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 10),
        ),
      };

      final breakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'food',
        tiles: tiles,
        castleLevel: 1,
        crowns: 0,
      );

      expect(breakdown.totalProduction, greaterThan(0.0));
      expect(breakdown.totalUntransported, greaterThan(0.0));
      expect(breakdown.producers.first.untransportedRate, greaterThan(0.0));
    });
  });
}
