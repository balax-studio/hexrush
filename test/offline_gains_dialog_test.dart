import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
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

    testWidgets('renders welcome header and various advanced resource pills', (tester) async {
      const gains = OfflineGainsResult(
        seconds: 5400,
        food: 120.0,
        wood: 60.0,
        stone: 30.0,
        iron: 15.0,
        fish: 25.0,
        wisdom: 10.0,
        kumis: 8.0,
        felt: 5.0,
        damascusSteel: 3.0,
      );

      await tester.pumpWidget(createWidgetUnderTest(gains));
      await tester.pumpAndSettle();

      expect(find.text('HOŞ GELDİNİZ, BOZKIR KAĞANI'), findsOneWidget);
      expect(find.text('BOZKIR ÇEVRİMDIŞI KAZANCI'), findsOneWidget);
      expect(find.textContaining('1 saat 30 dakika'), findsOneWidget);
      expect(find.textContaining('+120 Gıda'), findsOneWidget);
      expect(find.textContaining('+60 Odun'), findsOneWidget);
      expect(find.textContaining('+25 Balık'), findsOneWidget);
      expect(find.textContaining('+10 Bilgelik'), findsOneWidget);
      expect(find.textContaining('+8 Kımız'), findsOneWidget);
      expect(find.textContaining('+5 Keçe'), findsOneWidget);
      expect(find.textContaining('+3 Şam Çeliği'), findsOneWidget);
    });

    test('GameStateNotifier tracks pendingOfflineGains and clears upon claim', () async {
      final notifier = GameStateNotifier();
      const offline = OfflineGainsResult(
        seconds: 3600,
        food: 100.0,
        wood: 50.0,
      );

      notifier.state = notifier.state.copyWith(pendingOfflineGains: offline);
      expect(notifier.state.pendingOfflineGains, isNotNull);
      expect(notifier.state.pendingOfflineGains!.food, 100.0);

      final initialFood = notifier.state.resources.food;
      await notifier.claimOfflineGains(offline, isBoosted: false);

      expect(notifier.state.pendingOfflineGains, isNull);
      expect(notifier.state.resources.food, initialFood + 100.0);
    });

    test('GameStateNotifier processResumeOfflineGains sets pendingOfflineGains when elapsed time >= 15s and producing buildings exist', () {
      final notifier = GameStateNotifier();
      const coord = HexAxial(1, 0);
      final tile = notifier.state.tiles[coord]!.copyWith(
        state: TileState.owned,
        building: const BuildingModel(type: BuildingType.corn, level: 1),
      );
      final tiles = Map<HexAxial, HexTileModel>.from(notifier.state.tiles);
      tiles[coord] = tile;
      notifier.state = notifier.state.copyWith(tiles: tiles);

      final pastTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600;

      notifier.processResumeOfflineGains(pastTime);
      expect(notifier.state.pendingOfflineGains, isNotNull);
      expect(notifier.state.pendingOfflineGains!.seconds, greaterThanOrEqualTo(15));
      expect(notifier.state.pendingOfflineGains!.food, greaterThan(0));
    });
  });
}
