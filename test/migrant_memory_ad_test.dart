import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/widgets/migrant_memory_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createMigrantMemoryUnderTest({IAdRewardService? adService}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MigrantMemoryDialog(adService: adService),
        ),
      ),
    );
  }

  group('MigrantMemoryDialog Ad Integration Tests', () {
    testWidgets('renders Kutlu Miras ad reward section', (tester) async {
      await tester.pumpWidget(createMigrantMemoryUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('KUTLU MİRAS SANDIĞI'), findsOneWidget);
      expect(find.textContaining('+1 TAMGA AL'), findsOneWidget);
    });

    testWidgets('tapping legacy ad button claims +1 Tamga reward', (tester) async {
      final mockAdService = MockAdRewardService(shouldSucceed: true);
      await tester.pumpWidget(createMigrantMemoryUnderTest(adService: mockAdService));
      await tester.pumpAndSettle();

      final legacyBtn = find.textContaining('+1 TAMGA AL');
      await tester.tap(legacyBtn);
      await tester.pumpAndSettle();

      expect(mockAdService.adHistory.length, 1);
      expect(mockAdService.adHistory.first, AdRewardType.migrationLegacy);
    });
  });
}
