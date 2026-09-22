import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/top_bar_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Map Generation Determinism & Soft-Lock Prevention Tests', () {
    test('verifies initial map has guaranteed forest at (1,0) in radius 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(gameStateProvider);

      final forestTile = state.tiles[const HexAxial(1, 0)];
      expect(forestTile, isNotNull);
      expect(forestTile!.biome, equals(TileBiome.forest));
      expect(forestTile.state, equals(TileState.discovered));
    });

    test('verifies initial map has guaranteed mountain at (-2,3) in radius 3', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(gameStateProvider);

      final mountainTile = state.tiles[const HexAxial(-2, 3)];
      expect(mountainTile, isNotNull);
      expect(mountainTile!.biome, equals(TileBiome.mountain));
    });

    test('verifies initial map has guaranteed shrine at distance 4', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(gameStateProvider);

      final dist4Shrines = state.tiles.values.where((t) {
        final dist = t.coord.distanceTo(const HexAxial(0, 0));
        return dist == 4 && t.hasShrine;
      }).toList();

      expect(dist4Shrines, isNotEmpty);
      expect(dist4Shrines.first.shrine, equals(ShrineType.speedBoost));
    });

    test('building unlock castle levels follow progressive hierarchy', () {
      expect(BuildingType.lumberjack.requiredCastleLevel, equals(1));
      expect(BuildingType.corn.requiredCastleLevel, equals(1));
      expect(BuildingType.windmill.requiredCastleLevel, equals(5));
      expect(BuildingType.sawmill.requiredCastleLevel, equals(5));
      expect(BuildingType.quarry.requiredCastleLevel, equals(5));
      expect(BuildingType.mine.requiredCastleLevel, equals(15));
      expect(BuildingType.bakery.requiredCastleLevel, equals(15));
      expect(BuildingType.furniture.requiredCastleLevel, equals(20));
      expect(BuildingType.kumisYurt.requiredCastleLevel, equals(30));
      expect(BuildingType.damascusForge.requiredCastleLevel, equals(40));
    });
  });

  group('TopBarHUD Resource Discovery & Guidance Tests', () {
    testWidgets('renders TopBarHUD and opens secondary resource drawer', (tester) async {
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

      // TopBarHUD is rendered with council button
      expect(find.text('MECLİS'), findsOneWidget);

      // Tap drawer expand button
      final drawerButton = find.byTooltip('Genişletilmiş Envanter Çekmecesi');
      expect(drawerButton, findsOneWidget);
      await tester.tap(drawerButton);
      await tester.pump();
    });
  });
}
