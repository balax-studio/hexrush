import 'dart:math' as math;

/// Pointy-top altıgen ızgara için axial (q, r) koordinat sınıfı.
class HexAxial {
  final int q;
  final int r;

  const HexAxial(this.q, this.r);

  /// Cube coordinate s = -q - r
  int get s => -q - r;

  /// 6 komşu yönü (Axial: q, r)
  static const List<HexAxial> directions = [
    HexAxial(1, 0),
    HexAxial(1, -1),
    HexAxial(0, -1),
    HexAxial(-1, 0),
    HexAxial(-1, 1),
    HexAxial(0, 1),
  ];

  HexAxial operator +(HexAxial other) => HexAxial(q + other.q, r + other.r);
  HexAxial operator -(HexAxial other) => HexAxial(q - other.q, r - other.r);
  HexAxial operator *(int scale) => HexAxial(q * scale, r * scale);

  List<HexAxial> get neighbors => directions.map((d) => this + d).toList();

  /// Belirli bir yarıçap içindeki tüm koordinatları döndürür (Disk)
  List<HexAxial> getRange(int radius) {
    final List<HexAxial> results = [];
    for (int q = -radius; q <= radius; q++) {
      for (int r = math.max(-radius, -q - radius);
          r <= math.min(radius, -q + radius);
          r++) {
        results.add(this + HexAxial(q, r));
      }
    }
    return results;
  }

  /// İki eksenel koordinat arasındaki altıgen mesafesini (Hex Distance) hesaplar
  int distanceTo(HexAxial other) {
    return ((q - other.q).abs() + (q + r - other.q - other.r).abs() + (r - other.r).abs()) ~/ 2;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexAxial &&
          runtimeType == other.runtimeType &&
          q == other.q &&
          r == other.r;

  @override
  int get hashCode => Object.hash(q, r);

  @override
  String toString() => 'HexAxial($q, $r)';

  Map<String, dynamic> toJson() => {'q': q, 'r': r};

  factory HexAxial.fromJson(Map<String, dynamic> json) =>
      HexAxial(json['q'] as int? ?? json['x'] as int? ?? 0, json['r'] as int? ?? json['y'] as int? ?? 0);
}
