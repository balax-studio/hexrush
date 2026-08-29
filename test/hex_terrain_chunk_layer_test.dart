import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/flame/components/hex_terrain_chunk_layer.dart';

void main() {
  group('HexTerrainChunkLayer Tests', () {
    late HexTerrainChunkLayer layer;

    setUp(() {
      layer = HexTerrainChunkLayer();
    });

    tearDown(() {
      layer.dispose();
    });

    test('initial state is dirty and has no cache', () {
      expect(layer.isDirty, isTrue);
      expect(layer.hasCache, isFalse);
    });

    test('bake records picture and marks layer clean', () {
      int renderCallCount = 0;
      layer.bake((canvas) {
        renderCallCount++;
        canvas.drawRect(
          const Rect.fromLTWH(0, 0, 100, 100),
          Paint()..color = Colors.blue,
        );
      });

      expect(renderCallCount, equals(1));
      expect(layer.isDirty, isFalse);
      expect(layer.hasCache, isTrue);
    });

    test('render uses cached picture without executing callback when clean', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      int renderCallCount = 0;
      void draw(Canvas c) {
        renderCallCount++;
        c.drawRect(const Rect.fromLTWH(0, 0, 50, 50), Paint()..color = Colors.red);
      }

      // First render bakes
      layer.render(canvas, draw);
      expect(renderCallCount, equals(1));

      // Second render uses cached picture
      layer.render(canvas, draw);
      expect(renderCallCount, equals(1)); // Still 1!

      // Invalidate marks dirty
      layer.invalidate();
      expect(layer.isDirty, isTrue);

      // Third render re-bakes
      layer.render(canvas, draw);
      expect(renderCallCount, equals(2));

      recorder.endRecording();
    });
  });
}
