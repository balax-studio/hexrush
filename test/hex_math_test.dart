import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';

void main() {
  group('HexMath & HexAxial Tests', () {
    test('HexAxial neighbors returns exactly 6 distinct valid neighbors', () {
      const center = HexAxial(0, 0);
      final neighbors = center.neighbors;
      expect(neighbors.length, equals(6));
      expect(neighbors.toSet().length, equals(6));
      expect(neighbors, contains(const HexAxial(1, 0)));
      expect(neighbors, contains(const HexAxial(1, -1)));
      expect(neighbors, contains(const HexAxial(0, -1)));
      expect(neighbors, contains(const HexAxial(-1, 0)));
      expect(neighbors, contains(const HexAxial(-1, 1)));
      expect(neighbors, contains(const HexAxial(0, 1)));
    });

    test('hexDistance calculates correct axial distances', () {
      expect(HexMath.hexDistance(const HexAxial(0, 0), const HexAxial(0, 0)), equals(0));
      expect(HexMath.hexDistance(const HexAxial(0, 0), const HexAxial(1, 0)), equals(1));
      expect(HexMath.hexDistance(const HexAxial(0, 0), const HexAxial(2, 2)), equals(4));
      expect(HexMath.hexDistance(const HexAxial(-3, 1), const HexAxial(2, -2)), equals(5));
    });

    test('hexToPixel and pixelToHex roundtrip correctly', () {
      const testCoordinates = [
        HexAxial(0, 0),
        HexAxial(1, 0),
        HexAxial(0, 1),
        HexAxial(-2, 3),
        HexAxial(4, -5),
        HexAxial(-3, -2),
      ];

      for (final coord in testCoordinates) {
        final Offset pixel = HexMath.hexToPixel(coord, hexSize: 50.0, yScale: 0.85);
        final HexAxial recovered = HexMath.pixelToHex(pixel, hexSize: 50.0, yScale: 0.85);
        expect(recovered, equals(coord), reason: 'Failed for coord $coord at pixel $pixel');
      }
    });

    test('getHexCorners returns 6 offsets', () {
      final corners = HexMath.getHexCorners(const Offset(100, 100), hexSize: 40.0, yScale: 0.85);
      expect(corners.length, equals(6));
    });

    test('hexLine contains start and end', () {
      const start = HexAxial(0, 0);
      const end = HexAxial(3, -3);
      final line = HexMath.hexLine(start, end);
      expect(line.first, equals(start));
      expect(line.last, equals(end));
      expect(line.length, equals(4)); // distance is 3, length is 4
    });
  });
}
