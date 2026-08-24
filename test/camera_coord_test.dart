import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_idle/core/hex/hex_coordinates.dart';
import 'package:hex_idle/core/hex/hex_math.dart';

void main() {
  test('exact screen tap to hex conversion with camera pan and zoom', () {
    final world = World();
    final camera = CameraComponent(world: world);
    camera.viewfinder.position = Vector2(50, -30); // camera panned
    final double zoom = 1.25;
    camera.viewfinder.zoom = zoom;
    camera.viewport.size = Vector2(500, 800);

    const radius = 46.0;
    for (final coord in [
      const HexAxial(0, 0),
      const HexAxial(1, 0),
      const HexAxial(-1, 0),
      const HexAxial(0, 1),
      const HexAxial(0, -1),
      const HexAxial(1, -1),
      const HexAxial(-1, 1),
    ]) {
      // 1. World position of the hex
      final hexWorldPixel = HexMath.hexToPixel(coord, hexSize: radius);
      final worldPos = Vector2(hexWorldPixel.dx, hexWorldPixel.dy);

      // 2. Projected screen position
      // screenPos = (worldPos - cameraPos) * zoom + viewport.size / 2
      final screenPos = (worldPos - camera.viewfinder.position) * zoom + camera.viewport.size / 2;

      // 3. Reverse conversion on tap
      final unprojectedWorld = (screenPos - camera.viewport.size / 2) / zoom + camera.viewfinder.position;
      final recoveredHex = HexMath.pixelToHex(unprojectedWorld.toOffset(), hexSize: radius);

      expect(recoveredHex, equals(coord));
    }
  });
}
