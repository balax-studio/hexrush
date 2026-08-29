import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/graphics/hex_shader_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Post-Processing Diorama Shader Tests', () {
    setUp(() {
      HexShaderService.resetForTesting();
    });

    test('getDioramaShaderPaint returns gracefully in test environment', () {
      final paint = HexShaderService.getDioramaShaderPaint(
        resolution: const Size(800, 600),
        time: 1.0,
        dioramaStrength: 0.8,
      );

      expect(paint == null || paint.style == PaintingStyle.fill, isTrue);
    });
  });
}
