class_name HexMath
extends RefCounted

## Pointy-top altıgen ızgara matematiği ve koordinat dönüşüm sınıfı.
## Axial koordinat (q, r) sistemi kullanır.

# 6 komşunun yön vektörleri (Axial: q, r)
const NEIGHBOR_DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

## Axial koordinatı (q, r) 2D dünya pozisyonuna çevirir (İzometrik basıklık desteğiyle).
static func hex_to_pixel(q: int, r: int, hex_size: float, y_scale: float = 0.85) -> Vector2:
	var x: float = hex_size * sqrt(3.0) * (q + float(r) / 2.0)
	var y: float = hex_size * (3.0 / 2.0) * r * y_scale
	return Vector2(x, y)

## Verilen koordinatın 6 komşusunun koordinatlarını döndürür.
static func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for dir in NEIGHBOR_DIRECTIONS:
		neighbors.append(coord + dir)
	return neighbors

## Pointy-top altıgenin köşe noktalarını (Polygon için) hesaplar.
static func get_hex_corner_points(size: float, y_scale: float = 0.85) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(6):
		var angle_deg = 60.0 * i - 30.0 # Pointy-top açısı
		var angle_rad = deg_to_rad(angle_deg)
		var px = size * cos(angle_rad)
		var py = size * sin(angle_rad) * y_scale
		points.append(Vector2(px, py))
	return points

## 2D dünya pozisyonunu (x, y) en yakın axial altıgen koordinatına (Vector2i(q, r)) çevirir.
static func pixel_to_hex(px: float, py: float, hex_size: float, y_scale: float = 0.85) -> Vector2i:
	var unscaled_y = py / y_scale
	var q = (sqrt(3.0) / 3.0 * px - 1.0 / 3.0 * unscaled_y) / hex_size
	var r = (2.0 / 3.0 * unscaled_y) / hex_size
	return hex_round(q, r)

## Fractional kübik koordinatları en yakın altıgen koordinatına yuvarlar.
static func hex_round(q: float, r: float) -> Vector2i:
	var s = -q - r
	var rq = round(q)
	var rr = round(r)
	var rs = round(s)
	
	var q_diff = abs(rq - q)
	var r_diff = abs(rr - r)
	var s_diff = abs(rs - s)
	
	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs
	else:
		rs = -rq - rr
		
	return Vector2i(int(rq), int(rr))

## İki altıgen arasındaki mesafeyi (menzil) hesaplar
static func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var ax = a.x
	var az = a.y
	var ay = -ax - az
	var bx = b.x
	var bz = b.y
	var by = -bx - bz
	return int((abs(ax - bx) + abs(ay - by) + abs(az - bz)) / 2)

## İki altıgen arasındaki raycast / görüş hattı karolarını döndürür
static func hex_line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var n = hex_distance(a, b)
	var results: Array[Vector2i] = []
	if n == 0:
		results.append(a)
		return results
	for i in range(n + 1):
		var t = float(i) / float(n)
		var ax = float(a.x) + 0.00001
		var az = float(a.y) + 0.00001
		var ay = -ax - az
		var bx = float(b.x) + 0.00001
		var bz = float(b.y) + 0.00001
		var by = -bx - bz
		
		var x = ax + (bx - ax) * t
		var y = ay + (by - ay) * t
		var z = az + (bz - az) * t
		
		var rx = round(x)
		var ry = round(y)
		var rz = round(z)
		
		var x_diff = abs(rx - x)
		var y_diff = abs(ry - y)
		var z_diff = abs(rz - z)
		
		if x_diff > y_diff and x_diff > z_diff:
			rx = -ry - rz
		elif y_diff > z_diff:
			ry = -rx - rz
		else:
			rz = -rx - ry
			
		results.append(Vector2i(int(rx), int(rz)))
	return results
