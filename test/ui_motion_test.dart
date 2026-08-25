import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/diorama_lens_overlay.dart';
import 'package:hex_rush/presentation/widgets/quest_tracker_hud.dart';
import 'package:hex_rush/presentation/widgets/tactile_neo_button.dart';
import 'package:hex_rush/presentation/widgets/tile_action_sheet.dart';
import 'package:hex_rush/presentation/widgets/top_bar_hud.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Tactile Neo-Brutalism & Motion UI Tests', () {
    testWidgets('TactileNeoButton responds to tap and triggers callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TactileNeoButton(
                onTap: () {
                  pressed = true;
                },
                child: const Text('TEST BUTTON'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('TEST BUTTON'), findsOneWidget);

      // Tap on button
      await tester.tap(find.text('TEST BUTTON'));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('QuestTrackerHUD renders correctly within ProviderScope',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  QuestTrackerHUD(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuestTrackerHUD), findsOneWidget);
      expect(find.text('GÖREV'), findsOneWidget);

      container.dispose();
    });

    testWidgets('TopBarHUD renders resource counters and frenzy button',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TopBarHUD(
                    onOpenSettings: () {},
                    onOpenMarket: () {},
                    onOpenTore: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TopBarHUD), findsOneWidget);
      expect(find.byType(TactileNeoButton), findsWidgets);

      container.dispose();
    });

    testWidgets('DioramaLensOverlay renders visual gradient layers',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  DioramaLensOverlay(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(DioramaLensOverlay), findsOneWidget);

      container.dispose();
    });

    testWidgets('TileActionSheet renders when tile is selected',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      // Setup state with a selected tile
      final notifier = container.read(gameStateProvider.notifier);
      final coord = const HexAxial(1, 0);
      notifier.selectTile(coord);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  TileActionSheet(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TileActionSheet), findsOneWidget);
      expect(find.byType(TactileNeoButton), findsWidgets);

      container.dispose();
    });
  });
}
