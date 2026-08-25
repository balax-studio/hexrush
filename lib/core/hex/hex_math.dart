import 'dart:math' as math;
import 'dart:ui';
import 'hex_coordinates.dart';

/// Pointy-top altıgen ızgara matematiği ve koordinat dönüşüm motoru.
/// Axial koordinat (q, r) ve Gerçek 2.5D İzometrik basıklık (yScale = 0.58, tan(30°)) standartlarını kullanır.
class HexMath {
  static const double defaultYScale = 0.58;
  static const double defaultHexSize = 52.0;

  /// Axial koordinatı (q, r) 2D Canvas pozisyonuna çevirir.
  static Offset hexToPixel(
    HexAxial coord, {
    double hexSize = defaultHexSize,
    double yScale = defaultYScale,
  }) {
    final double x = hexSize * math.sqrt(3.0) * (coord.q + coord.r / 2.0);
    final double y = hexSize * (3.0 / 2.0) * coord.r * yScale;
    return Offset(x, y);
  }

  /// 2D Canvas pozisyonunu (x, y) en yakın axial altıgen koordinatına çevirir.
  static HexAxial pixelToHex(
    Offset position, {
    double hexSize = defaultHexSize,
    double yScale = defaultYScale,
  }) {
    final double unscaledY = position.dy / yScale;
    final double q =
        (math.sqrt(3.0) / 3.0 * position.dx - 1.0 / 3.0 * unscaledY) / hexSize;
    final double r = (2.0 / 3.0 * unscaledY) / hexSize;
    return hexRound(q, r);
  }

  /// Pointy-top izometrik altıgen içinde nokta kontrolü (Zero-GC, O(1))
  static bool isPointInsideHex(
    Offset point,
    Offset center, {
    double hexSize = defaultHexSize,
    double yScale = defaultYScale,
  }) {
    final double dx = (point.dx - center.dx).abs();
    final double dy = (point.dy - center.dy).abs() / yScale;
    if (dx > hexSize * 0.8660254037844386) return false;
    if (dy > hexSize) return false;
    return (dx * 0.5773502691896257 + dy) <= hexSize;
  }

  /// Fractional kübik koordinatları en yakın axial koordinata yuvarlar.
  static HexAxial hexRound(double q, double r) {
    final double s = -q - r;
    int rq = q.round();
    int rr = r.round();
    int rs = s.round();

    final double qDiff = (rq - q).abs();
    final double rDiff = (rr - r).abs();
    final double sDiff = (rs - s).abs();

    if (qDiff > rDiff && qDiff > sDiff) {
      rq = -rr - rs;
    } else if (rDiff > sDiff) {
      rr = -rq - rs;
    } else {
      rs = -rq - rr;
    }

    return HexAxial(rq, rr);
  }

  /// Pre-computed corner unit multipliers for 6 pointy-top corners (-30°, 30°, 90°, 150°, 210°, 270°)
  static const List<double> _cosAngles = [
    0.8660254037844386,  // cos(-30°)
    0.8660254037844386,  // cos(30°)
    0.0,                 // cos(90°)
    -0.8660254037844386, // cos(150°)
    -0.8660254037844386, // cos(210°)
    0.0,                 // cos(270°)
  ];

  static const List<double> _sinAngles = [
    -0.5, // sin(-30°)
    0.5,  // sin(30°)
    1.0,  // sin(90°)
    0.5,  // sin(150°)
    -0.5, // sin(210°)
    -1.0, // sin(270°)
  ];

  /// Pointy-top altıgenin köşe noktalarını (Canvas Path/Polygon için) sıfır heap tahsisiyle doldurur.
  static void getHexCornersInto(
    List<Offset> out,
    Offset center, {
    double hexSize = defaultHexSize,
    double yScale = defaultYScale,
    double dilation = 0.6,
  }) {
    final double effectiveSize = hexSize + dilation;
    final double cx = center.dx;
    final double cy = center.dy;
    for (int i = 0; i < 6; i++) {
      out[i] = Offset(
        cx + effectiveSize * _cosAngles[i],
        cy + effectiveSize * _sinAngles[i] * yScale,
      );
    }
  }

  /// Pointy-top altıgenin köşe noktalarını (Canvas Path/Polygon için) hesaplar.
  /// [dilation] parametresi (varsayılan 0.6px) alt-piksel rasterization yırtılmalarını ve dikiş boşluklarını yok eder.
  static List<Offset> getHexCorners(
    Offset center, {
    double hexSize = defaultHexSize,
    double yScale = defaultYScale,
    double dilation = 0.6,
  }) {
    final double effectiveSize = hexSize + dilation;
    final double cx = center.dx;
    final double cy = center.dy;
    return List<Offset>.generate(
      6,
      (i) => Offset(
        cx + effectiveSize * _cosAngles[i],
        cy + effectiveSize * _sinAngles[i] * yScale,
      ),
      growable: false,
    );
  }

  /// İki altıgen arasındaki mesafeyi (menzil) hesaplar.
  static int hexDistance(HexAxial a, HexAxial b) {
    final int ax = a.q;
    final int az = a.r;
    final int ay = -ax - az;

    final int bx = b.q;
    final int bz = b.r;
    final int by = -bx - bz;

    return ((ax - bx).abs() + (ay - by).abs() + (az - bz).abs()) ~/ 2;
  }

  /// İki altıgen arasındaki görüş hattı karolarını döndürür.
  static List<HexAxial> hexLine(HexAxial a, HexAxial b) {
    final int n = hexDistance(a, b);
    if (n == 0) return [a];

    final List<HexAxial> results = [];
    for (int i = 0; i <= n; i++) {
      final double t = i / n;
      final double ax = a.q + 0.00001;
      final double az = a.r + 0.00001;
      final double ay = -ax - az;

      final double bx = b.q + 0.00001;
      final double bz = b.r + 0.00001;
      final double by = -bx - bz;

      final double x = ax + (bx - ax) * t;
      final double y = ay + (by - ay) * t;
      final double z = az + (bz - az) * t;

      int rx = x.round();
      int ry = y.round();
      int rz = z.round();

      final double xDiff = (rx - x).abs();
      final double yDiff = (ry - y).abs();
      final double zDiff = (rz - z).abs();

      if (xDiff > yDiff && xDiff > zDiff) {
        rx = -ry - rz;
      } else if (yDiff > zDiff) {
        ry = -rx - rz;
      } else {
        rz = -rx - ry;
      }

      results.add(HexAxial(rx, rz));
    }
    return results;
  }
}
