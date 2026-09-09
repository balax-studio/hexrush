import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_rush/core/localization/game_localization.dart';
import 'package:hex_rush/presentation/widgets/settings_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsDialog & Privacy Policy Tests', () {
    testWidgets('renders SettingsDialog with privacy policy button in Turkish', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SettingsDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
      expect(find.text(GameLocalization.get('privacy_policy', lang: 'tr').toUpperCase()), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    test('verifies privacy policy localization keys in all supported languages', () {
      expect(GameLocalization.get('privacy_policy', lang: 'tr'), 'Gizlilik Politikası');
      expect(GameLocalization.get('privacy_policy', lang: 'en'), 'Privacy Policy');
      expect(GameLocalization.get('privacy_policy', lang: 'es'), 'Política de Privacidad');
      expect(GameLocalization.get('privacy_policy', lang: 'de'), 'Datenschutzerklärung');
    });
  });
}
