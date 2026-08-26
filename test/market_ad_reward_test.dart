import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/market_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createMarketUnderTest({IAdRewardService? adService}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MarketDialog(adService: adService),
        ),
      ),
    );
  }

  group('MarketDialog Ad Integration Tests', () {
    testWidgets('renders nomadic caravan bonus button and quota reset', (tester) async {
      await tester.pumpWidget(createMarketUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('GEZGİN KERVAN İKRAMI'), findsOneWidget);
    });

    testWidgets('tapping caravan ad button triggers claimAdReward and grants resources', (tester) async {
      final mockAdService = MockAdRewardService(shouldSucceed: true);
      await tester.pumpWidget(createMarketUnderTest(adService: mockAdService));
      await tester.pumpAndSettle();

      final caravanBtn = find.textContaining('AL (');
      await tester.tap(caravanBtn);
      await tester.pumpAndSettle();

      expect(mockAdService.adHistory.length, 1);
      expect(mockAdService.adHistory.first, AdRewardType.caravanBonus);
    });
  });
}
