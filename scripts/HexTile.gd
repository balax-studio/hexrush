class_name HexTile
extends Node2D

## Tekil bir altıgen arsasını temsil eden sınıf.
## Biyom çeşitliliği (Deniz, Çayır, Orman, Dağ) ve 3D İzometrik görsel detayları yönetir.

signal tile_clicked(tile: HexTile)

enum TileState {
	HIDDEN,      # Haritada henüz keşfedilmemiş (görünmez)
	DISCOVERED,  # Komşusu açıldığı için soluk görünen, keşfedilebilir arsa
	OWNED        # Oyuncunun açtığı/sahip olduğu tam canlı (opak) arsa
}

enum TileType {
	SEA,       # Deniz (Mavi)
	MEADOW,    # Çayır (Yeşil)
	FOREST,    # Orman (Koyu Yeşil)
	MOUNTAIN   # Dağ (Kahverengi)
}

@export var hex_size: float = 75.0
@export var y_scale: float = 0.85

var grid_coord: Vector2i = Vector2i.ZERO
var state: TileState = TileState.HIDDEN
var tile_type: TileType = TileType.MEADOW

var base_color: Color = Color(0.38, 0.78, 0.36)
var border_color: Color = Color(0.24, 0.55, 0.22)
var building: Node2D = null

var _wind_time: float = 0.0
var _tree_seeds: Array = []

@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionPolygon2D = $Area2D/CollisionPolygon2D

const BIOME_COLORS = {
	TileType.SEA: {
		"base": Color(0.18, 0.52, 0.88),       # Canlı Okyanus Mavisi
		"border": Color(0.12, 0.38, 0.68)
	},
	TileType.MEADOW: {
		"base": Color(0.38, 0.78, 0.36),     # Canlı Çayır Yeşili
		"border": Color(0.24, 0.55, 0.22)
	},
	TileType.FOREST: {
		"base": Color(0.12, 0.44, 0.18),     # Derin Zengin Orman Yeşili
		"border": Color(0.07, 0.28, 0.11)
	},
	TileType.MOUNTAIN: {
		"base": Color(0.52, 0.38, 0.26),   # Dağ/Toprak Kahverengi
		"border": Color(0.34, 0.23, 0.14)
	}
}

func _ready() -> void:
	_wind_time = randf() * 100.0
	
	# Rastgele ağaç ve çevre tohumları
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(grid_coord) + 1234
	_tree_seeds.clear()
	
	# Orman için 7 farklı izometrik ağaç konumu ve ölçeği
	var tree_configs = [
		{"pos": Vector2(-26, -16 * y_scale), "scale": 0.85, "var": 0},
		{"pos": Vector2(22, -22 * y_scale),  "scale": 0.95, "var": 1},
		{"pos": Vector2(0, -32 * y_scale),   "scale": 0.80, "var": 0},
		{"pos": Vector2(-12, -2 * y_scale),  "scale": 1.15, "var": 1},
		{"pos": Vector2(24, 6 * y_scale),    "scale": 1.05, "var": 0},
		{"pos": Vector2(-28, 14 * y_scale),  "scale": 0.88, "var": 1},
		{"pos": Vector2(6, 18 * y_scale),    "scale": 1.10, "var": 0}
	]
	# Y-Sort: Ekranda yukarıda olan ağaçlar önce çizilsin
	tree_configs.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
	_tree_seeds = tree_configs
	
	# Alanın tıklama poligonunu altıgen köşelerine göre ayarla
	var points = HexMath.get_hex_corner_points(hex_size, y_scale)
	if collision_shape:
		collision_shape.polygon = points
	_update_biome_colors()
	queue_redraw()

func _process(delta: float) -> void:
	if state != TileState.HIDDEN:
		_wind_time += delta * 2.5
		queue_redraw()

## Karo üzerinde bina olup olmadığını kontrol eder
func has_building() -> bool:
	return building != null and is_instance_valid(building)

## Karo üzerine bir bina/yapı (Şato, Mısır Tarlası vb.) ekler
func set_building(building_node: Node2D) -> void:
	if building and is_instance_valid(building):
		building.queue_free()
	building = building_node
	add_child(building)
	queue_redraw()

## Biyom türünü belirler ve renkleri günceller
func set_tile_type(new_type: TileType) -> void:
	tile_type = new_type
	_update_biome_colors()
	queue_redraw()

func _update_biome_colors() -> void:
	if BIOME_COLORS.has(tile_type):
		base_color = BIOME_COLORS[tile_type]["base"]
		border_color = BIOME_COLORS[tile_type]["border"]

## Arsanın durumunu belirler ve görsel geçişini animasyonla yapar
func set_state(new_state: TileState, animate: bool = true) -> void:
	state = new_state
	
	match state:
		TileState.HIDDEN:
			visible = false
			modulate.a = 0.0
		
		TileState.DISCOVERED:
			visible = true
			if animate:
				var tween = create_tween().set_parallel(true)
				tween.tween_property(self, "modulate:a", 0.65, 0.35).set_trans(Tween.TRANS_SINE)
				tween.tween_property(self, "scale", Vector2.ONE, 0.35).from(Vector2.ONE * 0.85)
			else:
				modulate.a = 0.65
				scale = Vector2.ONE
		
		TileState.OWNED:
			visible = true
			if animate:
				var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "modulate:a", 1.0, 0.25)
				
				var scale_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				scale_tween.tween_property(self, "scale", Vector2.ONE * 1.08, 0.12)
				scale_tween.tween_property(self, "scale", Vector2.ONE, 0.22)
			else:
				modulate.a = 1.0
				scale = Vector2.ONE

	queue_redraw()

# =============================================================================
# ÇİZİM & 3D İZOMETRİK BİYOM DETAYLARI
# =============================================================================

func _draw() -> void:
	if state == TileState.HIDDEN:
		return

	var points = HexMath.get_hex_corner_points(hex_size, y_scale)
	
	# 1. İzometrik Taban Kalınlığı / 3D Derinlik Efekti (Side Extrusion)
	var depth: float = 18.0 * y_scale
	var side_color = border_color.darkened(0.4)
	
	var bottom_p3 = points[2] + Vector2(0, depth)
	var bottom_p4 = points[3] + Vector2(0, depth)
	var bottom_p5 = points[4] + Vector2(0, depth)
	
	var side_poly_1 = PackedVector2Array([points[2], points[3], bottom_p4, bottom_p3])
	var side_poly_2 = PackedVector2Array([points[3], points[4], bottom_p5, bottom_p4])
	
	draw_colored_polygon(side_poly_1, side_color)
	draw_colored_polygon(side_poly_2, side_color.darkened(0.18))
	
	# 2. Üst Yüzey Dolgusu
	var fill = base_color
	if state == TileState.DISCOVERED:
		fill = base_color.lerp(Color(0.65, 0.72, 0.8), 0.25)
		
	draw_colored_polygon(points, fill)
	
	# 3. İzometrik Biyom Özel Nesneleri (Eğer üzerinde bina yoksa)
	if not has_building():
		match tile_type:
			TileType.FOREST:
				_draw_isometric_forest()
			TileType.MOUNTAIN:
				_draw_isometric_mountains()
			TileType.MEADOW:
				_draw_isometric_meadow_details()
			TileType.SEA:
				_draw_isometric_sea_ripples()
	
	# 4. Üst Yüzey Kenarlık Çizgileri
	var stroke = border_color
	if state == TileState.DISCOVERED:
		stroke = border_color.lightened(0.2)
		
	var loop_points = PackedVector2Array(points)
	loop_points.append(points[0])
	draw_polyline(loop_points, stroke, 2.5, true)
	
	# 5. Keşfedilmeyi Bekleyen Karolar İçin Artı Sembolü
	if state == TileState.DISCOVERED:
		var plus_color = Color(1.0, 1.0, 1.0, 0.85)
		var cross_size = 9.0
		draw_line(Vector2(-cross_size, 0), Vector2(cross_size, 0), plus_color, 2.2)
		draw_line(Vector2(0, -cross_size * y_scale), Vector2(0, cross_size * y_scale), plus_color, 2.2)

## 🌲 İzometrik 3D Orman ve Çam Ağaçları Çizimi
func _draw_isometric_forest() -> void:
	for tree in _tree_seeds:
		var pos: Vector2 = tree["pos"]
		var sc: float = tree["scale"]
		var tree_var: int = tree["var"]
		
		# Rüzgar salınımı
		var sway = sin(_wind_time + pos.x * 0.1 + pos.y * 0.2) * (1.8 * sc)
		
		# 1. Ağaç Altı Gölgesi (Soft Drop Shadow)
		var shadow_w = 14.0 * sc
		var shadow_h = 7.0 * sc * y_scale
		_draw_isometric_shadow(pos + Vector2(1, 2), shadow_w, shadow_h, Color(0.03, 0.12, 0.05, 0.45))
		
		# 2. 3D Ahşap Ağaç Gövdesi
		var trunk_w = 4.2 * sc
		var trunk_h = 10.0 * sc * y_scale
		var trunk_rect = Rect2(pos.x - trunk_w * 0.5, pos.y - trunk_h, trunk_w, trunk_h)
		draw_rect(trunk_rect, Color(0.35, 0.22, 0.12)) # Koyu gövde
		draw_line(Vector2(pos.x + trunk_w * 0.2, pos.y - trunk_h), Vector2(pos.x + trunk_w * 0.2, pos.y), Color(0.48, 0.32, 0.18), 1.2) # Işık çizgisi
		
		# 3. Üç Kademeli Hacimli Çam / İğne Yapraklı Tacı (Multi-Tiered Cones)
		# Renk Paleti: Güneş alan sağ taraf parlak, gölgede kalan sol taraf zengin koyu
		var fol_dark = Color(0.08, 0.32, 0.14) if tree_var == 0 else Color(0.12, 0.38, 0.18)
		var fol_light = Color(0.18, 0.58, 0.26) if tree_var == 0 else Color(0.24, 0.65, 0.32)
		var fol_highlight = Color(0.32, 0.78, 0.42)
		
		# Kademe 1 (En Alt Geniş Koni)
		var t1_y = pos.y - 7.0 * sc * y_scale
		var t1_w = 16.0 * sc
		var t1_h = 15.0 * sc * y_scale
		_draw_isometric_cone(Vector2(pos.x, t1_y), t1_w, t1_h, sway * 0.3, fol_dark, fol_light, fol_highlight)
		
		# Kademe 2 (Orta Koni)
		var t2_y = t1_y - 8.0 * sc * y_scale
		var t2_w = 12.5 * sc
		var t2_h = 14.0 * sc * y_scale
		_draw_isometric_cone(Vector2(pos.x, t2_y), t2_w, t2_h, sway * 0.6, fol_dark, fol_light, fol_highlight)
		
		# Kademe 3 (Tepe Zirve Konisi)
		var t3_y = t2_y - 8.0 * sc * y_scale
		var t3_w = 9.0 * sc
		var t3_h = 13.0 * sc * y_scale
		_draw_isometric_cone(Vector2(pos.x, t3_y), t3_w, t3_h, sway * 1.0, fol_dark, fol_light, fol_highlight)
		
		# Zirve Sivri Uç Işıltısı
		var tip_pos = Vector2(pos.x + sway, t3_y - t3_h)
		draw_circle(tip_pos, 1.2 * sc, Color(0.5, 0.9, 0.55, 0.8))

## Tek bir izometrik 3D ağaç konisi çizer (Işık ve gölge yüzeyli)
func _draw_isometric_cone(base_pos: Vector2, width: float, height: float, sway_x: float, col_dark: Color, col_light: Color, col_hi: Color) -> void:
	var left_pt = base_pos + Vector2(-width * 0.5, 0)
	var right_pt = base_pos + Vector2(width * 0.5, 0)
	var mid_base = base_pos + Vector2(0, width * 0.15 * y_scale)
	var apex = base_pos + Vector2(sway_x, -height)
	
	# Sol (Gölge) Yüzey
	var left_poly = PackedVector2Array([left_pt, mid_base, apex])
	draw_colored_polygon(left_poly, col_dark)
	
	# Sağ (Güneş Işığı) Yüzey
	var right_poly = PackedVector2Array([mid_base, right_pt, apex])
	draw_colored_polygon(right_poly, col_light)
	
	# Kenar ve Zirve Işıltı Çizgisi
	draw_line(apex, right_pt, col_hi, 1.2)
	draw_line(apex, mid_base, col_dark.darkened(0.2), 1.0)

## 🏔️ İzometrik 3D Karlı Dağ Zirveleri
func _draw_isometric_mountains() -> void:
	var peaks = [
		{"pos": Vector2(-15, 6 * y_scale), "w": 28.0, "h": 32.0 * y_scale},
		{"pos": Vector2(16, -6 * y_scale),  "w": 32.0, "h": 38.0 * y_scale},
		{"pos": Vector2(-2, -18 * y_scale), "w": 24.0, "h": 26.0 * y_scale}
	]
	peaks.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
	
	for p in peaks:
		var b_pos: Vector2 = p["pos"]
		var w: float = p["w"]
		var h: float = p["h"]
		
		var left_pt = b_pos + Vector2(-w * 0.5, 0)
		var right_pt = b_pos + Vector2(w * 0.5, 0)
		var mid_base = b_pos + Vector2(0, w * 0.15 * y_scale)
		var apex = b_pos + Vector2(0, -h)
		
		# Sol (Koyu) ve Sağ (Açık) Yüzeyler
		draw_colored_polygon(PackedVector2Array([left_pt, mid_base, apex]), Color(0.38, 0.28, 0.20))
		draw_colored_polygon(PackedVector2Array([mid_base, right_pt, apex]), Color(0.55, 0.42, 0.30))
		
		# Kar Şapkası (Zirve)
		var snow_h = h * 0.38
		var snow_left = apex.lerp(left_pt, 0.38)
		var snow_right = apex.lerp(right_pt, 0.38)
		var snow_mid = apex.lerp(mid_base, 0.42)
		draw_colored_polygon(PackedVector2Array([snow_left, snow_mid, apex]), Color(0.85, 0.90, 0.96))
		draw_colored_polygon(PackedVector2Array([snow_mid, snow_right, apex]), Color(0.96, 0.98, 1.0))

## 🌾 İzometrik Çayır Detayları
func _draw_isometric_meadow_details() -> void:
	var tufts = [
		Vector2(-16, -10 * y_scale),
		Vector2(14, 8 * y_scale),
		Vector2(0, -18 * y_scale)
	]
	for t in tufts:
		draw_line(t, t + Vector2(-3, -6 * y_scale), Color(0.48, 0.88, 0.42), 1.2)
		draw_line(t, t + Vector2(3, -7 * y_scale), Color(0.52, 0.92, 0.45), 1.2)

## 🌊 İzometrik Deniz Dalgaları
func _draw_isometric_sea_ripples() -> void:
	var wave_offset = sin(_wind_time * 1.2) * 3.0
	var wave_color = Color(0.45, 0.75, 1.0, 0.45)
	draw_arc(Vector2(-14 + wave_offset, -8 * y_scale), 8.0, 0.2, 2.8, 12, wave_color, 1.5)
	draw_arc(Vector2(12 - wave_offset, 6 * y_scale), 10.0, 0.2, 2.8, 12, wave_color, 1.5)

func _draw_isometric_shadow(center: Vector2, width: float, height: float, color: Color) -> void:
	var poly = PackedVector2Array()
	var segments = 10
	for i in range(segments):
		var angle = (float(i) / float(segments)) * TAU
		var px = center.x + cos(angle) * width * 0.5
		var py = center.y + sin(angle) * height * 0.5
		poly.append(Vector2(px, py))
	draw_colored_polygon(poly, color)

## Alanın (Area2D) fiziksel tıklama ve dokunmatik girişini yakalar
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if state == TileState.HIDDEN:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tile_clicked.emit(self)
	elif event is InputEventScreenTouch and event.pressed:
		tile_clicked.emit(self)