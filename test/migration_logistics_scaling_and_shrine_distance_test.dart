import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/great_migration_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Migration Logistics Scaling Tests (EconomyCalculator)', () {
    test('Her Büyük Göçte işçi ve ambar taşıma hacmi kalıcı olarak +%35 x Göç Sayısı artar', () {
      // 0 Göç: Temel 1.0x
      final mult0 = EconomyCalculator.getWorkerTransferMultiplier(totalMigrations: 0);
      expect(mult0, closeTo(1.0, 0.001));

      // 1 Göç: 1.35x (+%35)
      final mult1 = EconomyCalculator.getWorkerTransferMultiplier(totalMigrations: 1);
      expect(mult1, closeTo(1.35, 0.001));

      // 2 Göç: 1.70x (+%70)
      final mult2 = EconomyCalculator.getWorkerTransferMultiplier(totalMigrations: 2);
      expect(mult2, closeTo(1.70, 0.001));

      // 3 Göç: 2.05x (+%105)
      final mult3 = EconomyCalculator.getWorkerTransferMultiplier(totalMigrations: 3);
      expect(mult3, closeTo(2.05, 0.001));

      // Töre ve yetenek ile birleşik katlama kontrolü
      final combinedMult = EconomyCalculator.getWorkerTransferMultiplier(
        talents: {'workerSpeed': 2}, // +20%
        toreTalents: {'tonyukuk': {'pavedRoads': 1}}, // +8%
        totalMigrations: 2, // 1.70x
      );
      // (1.0 + 0.20 + 0.08) * (1.0 + 2 * 0.35) = 1.28 * 1.70 = 2.176
      expect(combinedMult, closeTo(1.28 * 1.70, 0.001));
    });
  });

  group('Kadim Sunak Yerleşimi ve Mesafe Orantılı Bonus Testleri', () {
    test('Şatoya 4 hex uzaktaki garantili sunak speedBoost türündedir ve merkezden uzaklaştıkça bonus artar', () {
      final notifier = GameStateNotifier();
      final state = notifier.state;
      const center = HexAxial(0, 0);

      // 1. Şatoya 4 hex uzaktaki garantili Kadim Sunak
      final dist4Shrines = state.tiles.values.where((t) {
        final dist = HexMath.hexDistance(center, t.coord);
        return dist == 4 && t.hasShrine;
      }).toList();

      expect(dist4Shrines, isNotEmpty);
      final speedShrine = dist4Shrines.first;
      expect(speedShrine.shrine, equals(ShrineType.speedBoost));
      expect(speedShrine.distanceFromCenter, equals(4));
      expect(speedShrine.shrineBonusPercentage, equals(20.0)); // 20 + 0
      expect(speedShrine.shrineBoostMultiplier, closeTo(0.20, 0.001));

      // 2. Diğer tüm sunaklar arasında minDistance >= 7 kuralı
      final allShrines = state.tiles.values.where((t) => t.hasShrine).toList();
      expect(allShrines.length, equals(11));

      for (int i = 0; i < allShrines.length; i++) {
        for (int j = i + 1; j < allShrines.length; j++) {
          final dist = HexMath.hexDistance(allShrines[i].coord, allShrines[j].coord);
          expect(dist >= 7, isTrue,
              reason: 'Sunaklar arası mesafe en az 7 olmalıdır: ${allShrines[i].coord} - ${allShrines[j].coord} ($dist)');
        }
      }

      // 3. Mesafe arttıkça bonus oranının artması kontrolü
      expect(ShrineType.foodBoost.calculateBoostPercentage(4), equals(30.0));
      expect(ShrineType.foodBoost.calculateBoostPercentage(5), equals(34.0));
      expect(ShrineType.foodBoost.calculateBoostPercentage(8), equals(46.0));

      expect(ShrineType.woodBoost.calculateBoostPercentage(4), equals(25.0));
      expect(ShrineType.woodBoost.calculateBoostPercentage(6), equals(33.0));

      expect(ShrineType.speedBoost.calculateBoostPercentage(4), equals(20.0));
      expect(ShrineType.speedBoost.calculateBoostPercentage(10), equals(44.0));
    });
  });

  group('GreatMigrationDialog Katsayılar & Rehber UI Testleri', () {
    testWidgets('GreatMigrationDialog açılır, 4 sütunlu mirası ve Göç Katsayıları Rehberini render eder', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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

      // Üst özet etiketleri
      expect(find.textContaining('TAÇ'), findsWidgets);
      expect(find.text('KUT KATSAYISI'), findsOneWidget);
      expect(find.text('TAŞIMA'), findsOneWidget);

      // Göç Sonrası Kazanım ve Artış Özeti (Yeni karşılaştırma paneli)
      expect(find.text('GÖÇ SONRASI KAZANIM VE ARTIŞ ÖZETİ'), findsOneWidget);
      expect(find.text('Tüm Kaynak Üretim Hızı (Kut)'), findsOneWidget);
      expect(find.text('İşçi & Ambar Taşıma Hacmi'), findsOneWidget);
      expect(find.textContaining('HIZ'), findsOneWidget);
      expect(find.textContaining('KAPASİTE'), findsOneWidget);

      // Göç Katsayıları ve Kazanım Rehberi
      expect(find.text('GÖÇ KATSAYILARI & KAZANIM REHBERİ'), findsOneWidget);
      expect(find.textContaining('Kalıcı Taşıma & Lojistik Hacmi'), findsOneWidget);
      expect(find.textContaining('Kut Bereketi & Üretim Çarpanı'), findsOneWidget);
      expect(find.textContaining('KATSAYILAR VE TAÇ NASIL KAZANILIR?'), findsOneWidget);
    });

    test('EconomyCalculator.calculateMigrationTamgas fethe göre doğru hesaplar', () {
      expect(EconomyCalculator.calculateMigrationTamgas(ownedCount: 20, ownedShrinesCount: 0), equals(10));
      expect(EconomyCalculator.calculateMigrationTamgas(ownedCount: 20, ownedShrinesCount: 2), equals(15));
      expect(EconomyCalculator.calculateMigrationTamgas(ownedCount: 40, ownedShrinesCount: 4), equals(30));
    });
  });
}
