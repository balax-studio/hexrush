import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/council_management_dialog.dart';
import 'package:hex_rush/presentation/widgets/crown_breakdown_dialog.dart';
import 'package:hex_rush/presentation/widgets/great_migration_dialog.dart';
import 'package:hex_rush/presentation/widgets/quest_tracker_hud.dart';
import 'package:hex_rush/presentation/widgets/tile_action_sheet.dart';
import 'package:hex_rush/presentation/widgets/top_bar_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const narrowScreens = [
    Size(320, 568), // iPhone SE 1st Gen
    Size(360, 640), // Compact Android
    Size(375, 667), // iPhone 8 / SE 2nd Gen
  ];

  for (final screenSize in narrowScreens) {
    group('Narrow Screen Layout Tests on ${screenSize.width}x${screenSize.height}', () {
      testWidgets('TopBarHUD renders without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TopBarHUD(
                  onOpenMarket: () {},
                  onOpenTore: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);

        // Open drawer
        final drawerButton = find.byTooltip('Genişletilmiş Envanter Çekmecesi');
        if (drawerButton.evaluate().isNotEmpty) {
          await tester.tap(drawerButton, warnIfMissed: false);
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('CouncilManagementDialog renders without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: CouncilManagementDialog(
                  onOpenMarket: () {},
                  onOpenTore: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print('CouncilManagementDialog error on ${screenSize.width}w:\n${err.toStringDeep()}');
        }
        expect(err, isNull);
      });

      testWidgets('QuestTrackerHUD renders without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: QuestTrackerHUD(),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('GreatMigrationDialog renders without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: GreatMigrationDialog(),
              ),
            ),
          ),
        );

        await tester.pump();
        final err = tester.takeException();
        if (err is FlutterError) {
          // ignore: avoid_print
          print('GreatMigrationDialog error on ${screenSize.width}w:\n${err.toStringDeep()}');
        }
        expect(err, isNull);
      });

      testWidgets('CrownBreakdownDialog renders without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: CrownBreakdownDialog(),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('TileActionSheet renders build options without overflow on ${screenSize.width}w', (tester) async {
        tester.view.physicalSize = screenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer();
        final notifier = container.read(gameStateProvider.notifier);
        notifier.selectTile(const HexAxial(0, 0));

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
        expect(tester.takeException(), isNull);
        expect(find.byType(TileActionSheet), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      });
    });
  }
}
