import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/widgets/council_management_dialog.dart';
import 'package:hex_rush/domain/models/game_state.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CouncilManagementDialog Widget Tests', () {
    testWidgets('renders all council actions and frenzy banner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CouncilManagementDialog(
                  onOpenMarket: () {},
                  onOpenTore: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('KURULTAY & YÖNETİM'), findsOneWidget);
      expect(find.text('Kağanlık İdari İşleri'), findsOneWidget);

      // Check Frenzy Banner
      expect(find.text('10X TOY COŞKUSU'), findsOneWidget);

      // Check 2x2 Grid Cards
      expect(find.text('İPEK YOLU PAZARI'), findsOneWidget);
      expect(find.text('TÖRE & DOKTRİN'), findsOneWidget);
      expect(find.text('BÜYÜK GÖÇ'), findsOneWidget);
      expect(find.text('OBAYI YÖNET'), findsOneWidget);
    });

    testWidgets('tapping market card triggers onOpenMarket callback', (tester) async {
      bool marketOpened = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CouncilManagementDialog(
                  onOpenMarket: () => marketOpened = true,
                  onOpenTore: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('İPEK YOLU PAZARI'));
      await tester.pumpAndSettle();
      expect(marketOpened, isTrue);
    });

    testWidgets('tapping tore card triggers onOpenTore callback', (tester) async {
      bool toreOpened = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CouncilManagementDialog(
                  onOpenMarket: () {},
                  onOpenTore: () => toreOpened = true,
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('TÖRE & DOKTRİN'));
      await tester.pumpAndSettle();
      expect(toreOpened, isTrue);
    });

    testWidgets('tapping settings card triggers onOpenSettings callback', (tester) async {
      bool settingsOpened = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CouncilManagementDialog(
                  onOpenMarket: () {},
                  onOpenTore: () {},
                  onOpenSettings: () => settingsOpened = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('OBAYI YÖNET'));
      await tester.pumpAndSettle();
      expect(settingsOpened, isTrue);
    });

    testWidgets('renders active 10x frenzy banner with remaining time', (tester) async {
      final notifier = GameStateNotifier();
      notifier.pauseGameLoop();
      notifier.state = notifier.state.copyWith(
        frenzyTimer: 235.0,
        frenzyMultiplier: 10,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => CouncilManagementDialog(
                  onOpenMarket: () {},
                  onOpenTore: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check active Frenzy Banner shows 10X TOY COŞKUSU with remaining time
      expect(find.text('10X TOY COŞKUSU (235s)'), findsOneWidget);
      expect(find.text('235s'), findsOneWidget);
      expect(find.text('10x üretim & lojistik verimi devrede'), findsOneWidget);
    });
  });
}
