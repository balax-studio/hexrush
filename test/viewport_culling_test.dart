import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/flame/renderers/viewport_culling_manager.dart';

void main() {
  group('ViewportCullingManager Tests', () {
    final culling = ViewportCullingManager.instance;

    setUp(() {
      culling.resetForTesting();
    });

    test('correctly identifies visible vs culled points', () {
      culling.updateVisibleBounds(
        const Rect.fromLTRB(-200, -200, 200, 200),
        margin: 50.0,
      ); // Effective bounds: -250, -250, 250, 250

      // Center is visible
      expect(culling.isVisible(const Offset(0, 0)), isTrue);
      // Inside margin is visible
      expect(culling.isVisible(const Offset(220, 220)), isTrue);
      // Way outside is culled
      expect(culling.isVisible(const Offset(400, 0)), isFalse);
      expect(culling.isVisible(const Offset(-500, 0)), isFalse);
      expect(culling.isVisible(const Offset(0, 600)), isFalse);
    });

    test('isRectVisible works accurately', () {
      culling.updateVisibleBounds(
        const Rect.fromLTRB(-100, -100, 100, 100),
        margin: 20.0,
      ); // Bounds: -120, -120, 120, 120

      // Overlapping rect
      expect(culling.isRectVisible(0, 0, 50, 50), isTrue);
      // Completely outside rect
      expect(culling.isRectVisible(200, 200, 300, 300), isFalse);
    });

    test('disabling culling allows all renders', () {
      culling.updateVisibleBounds(const Rect.fromLTRB(0, 0, 10, 10), margin: 0);
      culling.isEnabled = false;

      expect(culling.isVisible(const Offset(1000, 1000)), isTrue);
    });
  });
}
