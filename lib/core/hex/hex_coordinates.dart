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
