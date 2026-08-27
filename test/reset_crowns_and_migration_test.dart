import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/crown_breakdown_dialog.dart';
import 'package:hex_rush/presentation/widgets/great_migration_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Taç (Crowns) Ekonomisi & Reset Hesaplama Testleri', () {
    test('Taç pasif küresel üretim çarpanı sağlamaz', () {
      final double multWithoutCrowns = EconomyCalculator.getGlobalMultiplier(
        castleLevel: 1,
        crowns: 0,
      );
      final double multWith100Crowns = EconomyCalculator.getGlobalMultiplier(
        castleLevel: 1,
        crowns: 100,
      );

      // Taç pasif çarpan vermemeli, ikisi de 1.0 olmalı
      expect(multWithoutCrowns, equals(1.0));
      expect(multWith100Crowns, equals(1.0));
    });

    test('calculateResetCrownsBreakdown doğru dengeli değerleri hesaplar', () {
      final tiles = List.generate(
        15,
        (i) => HexTileModel(
          coord: HexAxial(i, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          shrine: i == 1 ? ShrineType.foodBoost : ShrineType.none,
          building: i == 0
              ? const BuildingModel(type: BuildingType.castle, level: 3)
              : BuildingModel(type: BuildingType.corn, level: i <= 5 ? 3 : 1),
        ),
      );

      const resources = ResourcesModel(
        food: 15000.0,
        wood: 10000.0, // Toplam 25.000 hammadde => 2 Taç
      );

      final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
        tiles: tiles,
        resources: resources,
        castleLevel: 3,
      );

      // 15 Hex ~/ 5 => 3 Taç
      expect(breakdown.hexCrowns, equals(3));
      // 25.000 hammadde (>=20.000) => 2 Taç
      expect(breakdown.resourceCrowns, equals(2));
      // Sunak (1) + Castle Sv.3 (3 ~/ 2 = 1) + 21 bina kademesi (21 ~/ 15 = 1) = 3 Taç
      expect(breakdown.buildingAndShrineCrowns, equals(3));
      // Toplam = 3 + 2 + 3 = 8 Taç
      expect(breakdown.totalCrowns, equals(8));
    });
  });

  group('Büyük Göç UI & Onay Akışı Widget Testleri', () {
    testWidgets('CrownBreakdownDialog açılır ve doğru dökümü gösterir', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CrownBreakdownDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ŞAN & TAÇ DÖKÜMÜ'), findsOneWidget);
      expect(find.text('Hüküm Sürülen Topraklar (Hexler)'), findsOneWidget);
      expect(find.text('Ambar ve Hammadde Stoğu'), findsOneWidget);
      expect(find.text('BÜYÜK GÖÇ'), findsOneWidget);
    });

    testWidgets('GreatMigrationDialog açılır ve onay modalı tetiklenebilir', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GreatMigrationDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BÜYÜK GÖÇ (PRESTİJ & ÇAĞ ATLAYIŞI)'), findsOneWidget);
      expect(find.text('BÜYÜK GÖÇÜ BAŞLAT'), findsOneWidget);

      // Butona bas
      await tester.tap(find.text('BÜYÜK GÖÇÜ BAŞLAT'));
      await tester.pumpAndSettle();

      // Onay modalı çıkmalı
      expect(find.text('BÜYÜK GÖÇÜ ONAYLIYOR MUSUNUZ?'), findsOneWidget);
      expect(find.text('EVET, GÖÇÜ BAŞLAT'), findsOneWidget);
      expect(find.text('İPTAL'), findsOneWidget);

      // İptale basınca onay modalı kapanmalı
      await tester.tap(find.text('İPTAL'));
      await tester.pumpAndSettle();

      expect(find.text('BÜYÜK GÖÇÜ ONAYLIYOR MUSUNUZ?'), findsNothing);
    });
  });
}
