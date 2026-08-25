import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/main.dart';
import 'package:hex_rush/presentation/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HexRushApp pumps successfully and renders GameScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HexRushApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
