import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/widgets/neo_brutalist_loading_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NeoBrutalistHexLoader Component Tests', () {
    testWidgets('renders polygon monolith header and telemetry readout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoBrutalistHexLoader(
                statusText: 'KADİM BOZKIR MATRİSİ',
                subText: 'İzometrik Voksel Motoru Aktif...',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('KADİM BOZKIR MATRİSİ'), findsOneWidget);
      expect(find.text('YÜKLENİYOR'), findsOneWidget);
      expect(find.text('İzometrik Voksel Motoru Aktif...'), findsOneWidget);

      // Verify custom painter is rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
