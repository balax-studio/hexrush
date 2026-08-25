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

  /// Verilen koordinatın 6 komşusunu döndürür.
  static List<HexAxial> getNeighbors(HexAxial coord) {
    return coord.neighbors;
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
    final List<Offset> corners = [];
    for (int i = 0; i < 6; i++) {
      final double angleDeg = 60.0 * i - 30.0;
      final double angleRad = angleDeg * (math.pi / 180.0);
      final double px = center.dx + effectiveSize * math.cos(angleRad);
      final double py = center.dy + effectiveSize * math.sin(angleRad) * yScale;
      corners.add(Offset(px, py));
    }
    return corners;
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
