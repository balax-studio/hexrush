import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_idle/main.dart';
import 'package:hex_idle/presentation/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HexIdleApp pumps successfully and renders GameScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HexIdleApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
