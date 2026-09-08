import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/intro_story_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Bozkır Destanı & Başlangıç Giriş Hikayesi Testleri', () {
    test('1. ProgressionModel hasSeenIntro varsayılan değeri ve serileştirme kontrolü', () {
      const progression = ProgressionModel();
      expect(progression.hasSeenIntro, isFalse);

      final updated = progression.copyWith(hasSeenIntro: true);
      expect(updated.hasSeenIntro, isTrue);

      final json = updated.toJson();
      expect(json['has_seen_intro'], isTrue);

      final fromJson = ProgressionModel.fromJson(json);
      expect(fromJson.hasSeenIntro, isTrue);
    });

    test('2. GameStateNotifier completeIntroStory tetiklendiğinde hasSeenIntro true olmalıdır', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.progression.hasSeenIntro, isFalse);

      notifier.completeIntroStory();
      expect(notifier.state.progression.hasSeenIntro, isTrue);
    });

    testWidgets('3. IntroStoryDialog render ve 3 sahne gezintisi, Maceraya Başla butonu', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IntroStoryDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // İlk sahne doğrulaması: ŞAFAK VE İLK OCAK
      expect(find.text('BOZKIRIN DOĞUŞU'), findsOneWidget);
      expect(find.text('BÖLÜM I'), findsOneWidget);
      expect(find.text('ŞAFAK VE İLK OCAK'), findsOneWidget);
      expect(find.text('İLERİ'), findsOneWidget);

      // İleri butonuna bas
      await tester.tap(find.text('İLERİ'));
      await tester.pumpAndSettle();

      // İkinci sahne doğrulaması: BENGÜ TAŞ VE KADİM TÖRE
      expect(find.text('BÖLÜM II'), findsOneWidget);
      expect(find.text('BENGÜ TAŞ VE KADİM TÖRE'), findsOneWidget);
      expect(find.text('GERİ'), findsOneWidget);

      // Tekrar İleri bas
      await tester.tap(find.text('İLERİ'));
      await tester.pumpAndSettle();

      // Üçüncü sahne: KUTLU FETİH VE KOZMİK ZİRVE ve MACERAYA BAŞLA
      expect(find.text('BÖLÜM III'), findsOneWidget);
      expect(find.text('KUTLU FETİH VE KOZMİK ZİRVE'), findsOneWidget);
      expect(find.text('MACERAYA BAŞLA'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
