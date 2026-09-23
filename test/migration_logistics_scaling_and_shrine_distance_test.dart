import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
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
    test('Göçlerde hesaplanan Kut üretim verim artışı taşımaya da birebir yansır', () {
      // Kut = 1.0x (Varsayılan başlangıç)
      final mult0 = EconomyCalculator.getWorkerTransferMultiplier(kutMultiplier: 1.0);
      expect(mult0, closeTo(1.0, 0.001));

      // 1 Göç (Kut = 1.05x -> +%5)
      final kut1 = EconomyCalculator.calculateKutMultiplier(totalMigrations: 1, tamgas: 0);
      final mult1 = EconomyCalculator.getWorkerTransferMultiplier(kutMultiplier: kut1);
      expect(mult1, closeTo(1.05, 0.001));

      // Kut = 1.50x
      final multCustom = EconomyCalculator.getWorkerTransferMultiplier(kutMultiplier: 1.50);
      expect(multCustom, closeTo(1.50, 0.001));

      // Töre, yetenek ve Kut çarpanı birleşik kontrolü
      final combinedMult = EconomyCalculator.getWorkerTransferMultiplier(
        talents: {'workerSpeed': 2}, // +20%
        toreTalents: {'tonyukuk': {'pavedRoads': 1}}, // +8%
        kutMultiplier: 1.50,
      );
      // (1.0 + 0.20 + 0.08) * 1.50 = 1.28 * 1.50 = 1.92
      expect(combinedMult, closeTo(1.28 * 1.50, 0.001));
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
      expect(speedShrine.shrineBonusPercentage, greaterThanOrEqualTo(200.0));
      expect(speedShrine.shrineBoostMultiplier, greaterThanOrEqualTo(1.0));

      // 2. Diğer tüm sunaklar arasında minDistance >= 5 kuralı
      final allShrines = state.tiles.values.where((t) => t.hasShrine).toList();
      expect(allShrines.length, equals(11));

      for (int i = 0; i < allShrines.length; i++) {
        for (int j = i + 1; j < allShrines.length; j++) {
          final dist = HexMath.hexDistance(allShrines[i].coord, allShrines[j].coord);
          expect(dist >= 5, isTrue,
              reason: 'Sunaklar arası mesafe en az 5 olmalıdır: ${allShrines[i].coord} - ${allShrines[j].coord} ($dist)');
        }
      }
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
      expect(find.text('İşçi & Gıda Ambarı Taşıma Hacmi'), findsOneWidget);
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
