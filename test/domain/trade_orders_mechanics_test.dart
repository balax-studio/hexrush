import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('İpek Yolu (Silk Road) Trade Orders Mechanics Test Suite', () {
    test('1. Başlangıç siparişleri 100x kaynak, 0 taç ve 3x hız buff süresi içerir', () {
      final orders = EconomyCalculator.generateInitialTradeOrders();
      expect(orders.length, equals(3));

      // 1. Sipariş (Bizans): 8000 odun, 4000 ekmek, 0 taç, 1800 sn (30 dk) buff
      expect(orders[0].requiredResources['wood'], equals(8000.0));
      expect(orders[0].requiredResources['bread'], equals(4000.0));
      expect(orders[0].rewardCrowns, equals(0));
      expect(orders[0].buffDurationSeconds, equals(1800));

      // 2. Sipariş (Soğd): 6000 taş, 5000 un, 2000 demir, 0 taç, 2700 sn (45 dk) buff
      expect(orders[1].requiredResources['stone'], equals(6000.0));
      expect(orders[1].requiredResources['flour'], equals(5000.0));
      expect(orders[1].requiredResources['iron'], equals(2000.0));
      expect(orders[1].rewardCrowns, equals(0));
      expect(orders[1].buffDurationSeconds, equals(2700));

      // 3. Sipariş (Sasani): 4000 mobilya, 5000 ekmek, 10000 yiyecek, 0 taç, 3600 sn (60 dk) buff
      expect(orders[2].requiredResources['furniture'], equals(4000.0));
      expect(orders[2].requiredResources['bread'], equals(5000.0));
      expect(orders[2].requiredResources['food'], equals(10000.0));
      expect(orders[2].rewardCrowns, equals(0));
      expect(orders[2].buffDurationSeconds, equals(3600));
    });

    test('2. Sipariş teslim edildiğinde 30 dk (1800 sn) kilitlenir ve taç vermez', () {
      final notifier = GameStateNotifier();
      final initialOrders = EconomyCalculator.generateInitialTradeOrders();
      final order = initialOrders[0];

      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(
          wood: 20000.0,
          bread: 20000.0,
          crowns: 10,
        ),
      );

      final beforeCrowns = notifier.state.resources.crowns;
      final beforeFrenzy = notifier.state.frenzyTimer;

      final bool fulfilled = notifier.fulfillTradeOrder(order.id);
      expect(fulfilled, isTrue);

      // Taç değişmemeli
      expect(notifier.state.resources.crowns, equals(beforeCrowns));
      // Altın çağ buff'ı 30 dk eklenmeli
      expect(notifier.state.frenzyTimer, equals(beforeFrenzy + 1800.0));

      // Slot kilitlenmeli
      final updatedOrder = notifier.state.progression.activeTradeOrders.firstWhere((o) => o.id == order.id);
      expect(updatedOrder.isFulfilled, isTrue);
      expect(updatedOrder.isLocked(), isTrue);
      expect(updatedOrder.getRemainingSeconds(), greaterThanOrEqualTo(1790));
      expect(notifier.state.progression.dailyTradeOrdersCompletedCount, equals(1));
    });

    test('3. Günlük periyot içinde 30 dk sonra gelen yeni sipariş 10 katı talep eder', () {
      // 1. Seviye tamamlandıktan sonra gelen sipariş (dailyCycleIndex = 1 -> 10x)
      final level1Order = EconomyCalculator.generateTradeOrderForSlot(0, dailyCycleIndex: 1);
      expect(level1Order.requiredResources['wood'], equals(80000.0)); // 8000 * 10
      expect(level1Order.requiredResources['bread'], equals(40000.0)); // 4000 * 10
      expect(level1Order.rewardCrowns, equals(0));

      // 2. Seviye tamamlandıktan sonra gelen sipariş (dailyCycleIndex = 2 -> 100x)
      final level2Order = EconomyCalculator.generateTradeOrderForSlot(0, dailyCycleIndex: 2);
      expect(level2Order.requiredResources['wood'], equals(800000.0)); // 8000 * 100
      expect(level2Order.requiredResources['bread'], equals(400000.0)); // 4000 * 100
      expect(level2Order.rewardCrowns, equals(0));
    });

    test('4. Gün bittiğinde (farklı tarih) sipariş çarpanı x1 başlangıç değerine sıfırlanır', () {
      final notifier = GameStateNotifier();
      // Dünün tarihi ve 3 sipariş tamamlanmış olsun
      notifier.state = notifier.state.copyWith(
        progression: notifier.state.progression.copyWith(
          dailyTradeOrdersCompletedCount: 3,
          lastTradeResetDate: '2026-08-25', // Geçmiş gün
        ),
      );

      // Game tick çalıştığında günün değiştiği tespit edilmeli ve 0'a sıfırlanmalı
      notifier.testTick();

      expect(notifier.state.progression.dailyTradeOrdersCompletedCount, equals(0));
      expect(notifier.state.progression.lastTradeResetDate, equals(DateTime.now().toIso8601String().substring(0, 10)));
    });
  });
}
