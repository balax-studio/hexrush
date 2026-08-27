import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/widgets/offline_gains_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(OfflineGainsResult result, {IAdRewardService? adService}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: OfflineGainsDialog(
            gains: result,
            adService: adService,
          ),
        ),
      ),
    );
  }

  group('OfflineGainsDialog Widget Tests', () {
    testWidgets('renders offline gains and both standard and ad boost buttons', (tester) async {
      const gains = OfflineGainsResult(
        seconds: 7200,
        food: 100.0,
        wood: 50.0,
        stone: 20.0,
      );

      await tester.pumpWidget(createWidgetUnderTest(gains));
      await tester.pumpAndSettle();

      expect(find.text('BOZKIR ÇEVRİMDIŞI KAZANCI'), findsOneWidget);
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('50'), findsWidgets);
      expect(find.text('TOPLA'), findsOneWidget);
      expect(find.textContaining('1.5X TOPLA'), findsOneWidget);
    });

    testWidgets('clicking standard collect closes dialog and claims normal amount', (tester) async {
      const gains = OfflineGainsResult(
        seconds: 3600,
        food: 60.0,
        wood: 40.0,
      );

      await tester.pumpWidget(createWidgetUnderTest(gains));
      await tester.pumpAndSettle();

      final standardButton = find.text('TOPLA');
      await tester.tap(standardButton);
      await tester.pumpAndSettle();
    });

    testWidgets('clicking ad boost triggers ad service and claims 1.5x boosted gains', (tester) async {
      final mockAdService = MockAdRewardService(shouldSucceed: true);
      const gains = OfflineGainsResult(
        seconds: 3600,
        food: 80.0,
        wood: 40.0,
      );

      await tester.pumpWidget(createWidgetUnderTest(gains, adService: mockAdService));
      await tester.pumpAndSettle();

      final adButton = find.textContaining('1.5X TOPLA');
      await tester.tap(adButton);
      await tester.pumpAndSettle();

      expect(mockAdService.adHistory.length, 1);
      expect(mockAdService.adHistory.first, AdRewardType.offlineProgressBoost);
    });
  });
}
