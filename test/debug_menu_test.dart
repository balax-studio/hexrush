import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/debug_menu_dialog.dart';
import 'package:hex_rush/presentation/widgets/offline_gains_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DebugMenuDialog Widget Tests', () {
    testWidgets('DebugMenuDialog renders sections and handles actions', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testCoord = const HexAxial(0, 1);
      final tile = HexTileModel(
        coord: testCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 5),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) {
              final notifier = GameStateNotifier();
              notifier.state = notifier.state.copyWith(
                selectedCoord: testCoord,
                tiles: {
                  ...notifier.state.tiles,
                  testCoord: tile,
                },
              );
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DebugMenuDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('GELİŞTİRİCİ DENETİM KONSOLU'), findsOneWidget);

      // Verify Offline simulation buttons
      expect(find.text('15 DK AFK'), findsOneWidget);
      expect(find.text('1 SAAT AFK'), findsOneWidget);
      expect(find.text('8 SAAT AFK'), findsOneWidget);

      // Verify Resource cheats
      expect(find.text('+10K TEMEL KAYNAKLAR'), findsOneWidget);

      // Verify Milestones tests
      expect(find.text('SEVİYE 9 YAP (➜ 10)'), findsOneWidget);

      // Verify Map and Fog controls
      expect(find.text('TÜM SİSLERİ AÇ'), findsOneWidget);
      expect(find.text('SİSLERİ GERİ KAPAT'), findsOneWidget);

      // Tap 15 DK AFK and check if OfflineGainsDialog opens
      await tester.tap(find.text('15 DK AFK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('HOŞ GELDİNİZ, BOZKIR KAĞANI'), findsOneWidget);

      // Verify only Food is produced in OfflineGainsDialog (because we only have a corn building at level 5)
      // Stone and iron should NOT be in the OfflineGainsDialog
      expect(
        find.descendant(
          of: find.byType(OfflineGainsDialog),
          matching: find.textContaining('TAŞ'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(OfflineGainsDialog),
          matching: find.textContaining('DEMİR'),
        ),
        findsNothing,
      );
    });
  });
}
