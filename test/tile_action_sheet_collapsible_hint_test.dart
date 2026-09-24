import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/tile_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TileActionSheet collapsible tutorial tips: close with X and reopen with help icon', (tester) async {
    const coord = HexAxial(1, 0);
    const tile = HexTileModel(
      coord: coord,
      biome: TileBiome.meadow,
      state: TileState.owned,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateProvider.overrideWith((ref) {
            final notifier = GameStateNotifier();
            notifier.state = notifier.state.copyWith(
              selectedCoord: coord,
              tiles: {coord: tile},
              progression: notifier.state.progression.copyWith(tutorialStep: 0),
            );
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TileActionSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tutorial hint text is visible
    expect(find.textContaining('Ötüken ovasında ilk obanı'), findsOneWidget);

    // Find the close X button inside the tutorial banner and tap it
    final closeIcons = find.byIcon(Icons.close);
    // At least 2 close icons: 1 in header, 1 in tutorial banner
    expect(closeIcons, findsNWidgets(2));

    // Tap the first close button (in tutorial banner)
    await tester.tap(closeIcons.first);
    await tester.pumpAndSettle();

    // Tutorial hint is now collapsed/hidden
    expect(find.textContaining('Ötüken ovasında ilk obanı'), findsNothing);

    // Help icon (question mark) should now appear in the header
    final helpIcon = find.byIcon(Icons.help_outline);
    expect(helpIcon, findsOneWidget);

    // Tap the help icon to reopen the tips
    await tester.tap(helpIcon);
    await tester.pumpAndSettle();

    // Tutorial hint is visible again
    expect(find.textContaining('Ötüken ovasında ilk obanı'), findsOneWidget);
  });
}
