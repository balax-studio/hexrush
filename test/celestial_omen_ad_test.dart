import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/celestial_omen_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createOmenHudUnderTest({IAdRewardService? adService}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: CelestialOmenHud(adService: adService),
        ),
      ),
    );
  }

  group('CelestialOmenHud Ad Integration Tests', () {
    testWidgets('tapping omen chip opens shaman blessing modal', (tester) async {
      await tester.pumpWidget(createOmenHudUnderTest());
      await tester.pumpAndSettle();

      final omenChip = find.byType(CelestialOmenHud);
      await tester.tap(omenChip);
      await tester.pumpAndSettle();

      expect(find.textContaining('ŞAMAN KEHANETİ & GÖK BEREKETİ'), findsOneWidget);
      expect(find.textContaining('GÖK TENGRİ DUASI'), findsOneWidget);
    });

    testWidgets('tapping blessing ad button claims celestial blessing', (tester) async {
      final mockAdService = MockAdRewardService(shouldSucceed: true);
      await tester.pumpWidget(createOmenHudUnderTest(adService: mockAdService));
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.byType(CelestialOmenHud));
      await tester.pumpAndSettle();

      // Tap ad blessing button
      final blessingBtn = find.textContaining('DUAYI KABUL ET');
      await tester.tap(blessingBtn);
      await tester.pumpAndSettle();

      expect(mockAdService.adHistory.length, 1);
      expect(mockAdService.adHistory.first, AdRewardType.celestialBlessing);
    });
  });
}
