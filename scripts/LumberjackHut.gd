class_name LumberjackHut
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu Kütük Oduncu Kulübesi, Kereste Sundurması, İstifli Kütükler ve Baltalı Kütük.

@export var hut_scale: float = 1.0
@export var y_scale: float = 0.85

# Üretim ve Seviye Durumu (Idle Kingdom Clicker Matematiği)
const FILL_DURATION: float = 30.0     # 30 saniyede tam dolum süresi

var level: int = 1
var production_rate: float = 0.35     # Saniyede üretilen odun miktarı (0.35 🪵/sn)
var max_capacity: float = 10.50       # 30 sn x 0.35 = 10.50 🪵 kapasite tavanı
var accumulated_wood: float = 0.0    # Tarlada/kulübede biriken odun miktarı
var upgrade_cost: int = 2            # Geliştirme bedeli (Gıda/Odun)

var _time: float = 0.0

# Renk Paleti (Koyu orman ağacı, taze kesilmiş odun, kütükler ve demir balta)
const STONE_DARK = Color(0.42, 0.45, 0.50)
const LOG_BARK = Color(0.48, 0.32, 0.20)         # Kütük dış kabuk rengi
const LOG_BARK_SHADE = Color(0.35, 0.22, 0.12)
const LOG_CORE = Color(0.82, 0.68, 0.45)         # Kesilmiş kütük iç açık halka rengi
const WOOD_PLANK = Color(0.65, 0.48, 0.32)
const ROOF_WOOD = Color(0.38, 0.26, 0.16)        # Ahşap kiremit çatı
const ROOF_WOOD_LIGHT = Color(0.52, 0.36, 0.22)
const AXE_METAL = Color(0.85, 0.88, 0.92)
const AXE_HANDLE = Color(0.30, 0.20, 0.12)
const CHIPS_COLOR = Color(0.92, 0.80, 0.55)      # Yerdeki taze odun talaşları
const DOOR_DARK = Color(0.20, 0.14, 0.08)

func _ready() -> void:
	# Başlangıç kapasitesini 30 saniyelik üretime eşitle
	max_capacity = snapped(production_rate * FILL_DURATION, 0.1)
	
	# Açılışta topraktan fışkırma / elastik pop-in animasyonu
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * hut_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.0
	# Pasif odun üretimi (30 saniyede dolacak şekilde max_capacity ile sınırlı)
	accumulated_wood = min(max_capacity, accumulated_wood + (production_rate * delta))
	queue_redraw()

## Kapasitenin dolup dolmadığını döndürür
func is_full() -> bool:
	return accumulated_wood >= (max_capacity - 0.01)

## Biriken odunu hasat eder ve miktarını döndürür
func collect_wood() -> float:
	var collected = accumulated_wood
	accumulated_wood = 0.0
	
	# Hasat pop animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (hut_scale * 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * hut_scale, 0.2)
	
	return collected

## Oduncu kulübesini bir üst seviyeye geliştirir (Hız ve kapasite birlikte artar)
func upgrade() -> void:
	level += 1
	production_rate = snapped(production_rate * 1.5, 0.01)
	max_capacity = snapped(production_rate * FILL_DURATION, 0.1)
	upgrade_cost = int(round(upgrade_cost * 1.8)) + 1
	
	# Geliştirme animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (hut_scale * 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * hut_scale, 0.3)

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Zemin talaşları
	var chips_pts = [
		Vector2(-18, 12), Vector2(-12, 18), Vector2(15, 14),
		Vector2(20, 8), Vector2(6, 20), Vector2(-8, 22)
	]
	for cp in chips_pts:
		draw_circle(iso(cp.x, cp.y, 0), 1.8, CHIPS_COLOR)

	# 2. Kulübe Taban Taşı
	var w_base = 16.0
	var d_base = 14.0
	var h_base = 4.0
	var p_f = iso(0, d_base, 0)
	var p_l = iso(-w_base, 0, 0)
	var p_r = iso(w_base, 0, 0)
	var p_f_top = iso(0, d_base, h_base)
	var p_l_top = iso(-w_base, 0, h_base)
	var p_r_top = iso(w_base, 0, h_base)
	
	draw_colored_polygon(PackedVector2Array([p_l, p_f, p_f_top, p_l_top]), STONE_DARK.lightened(0.08))
	draw_colored_polygon(PackedVector2Array([p_f, p_r, p_r_top, p_f_top]), STONE_DARK)

	# 3. Yatay Kütük Duvarlar
	var w_hut = 13.0
	var d_hut = 11.0
	var h_wall = 18.0
	
	var w_f = iso(0, d_hut, h_base)
	var w_l = iso(-w_hut, 0, h_base)
	var w_r = iso(w_hut, 0, h_base)
	var w_f_top = iso(0, d_hut, h_base + h_wall)
	var w_l_top = iso(-w_hut, 0, h_base + h_wall)
	var w_r_top = iso(w_hut, 0, h_base + h_wall)
	
	draw_colored_polygon(PackedVector2Array([w_l, w_f, w_f_top, w_l_top]), LOG_BARK)
	draw_colored_polygon(PackedVector2Array([w_f, w_r, w_r_top, w_f_top]), LOG_BARK_SHADE)
	
	var log_layers = 4
	for l in range(log_layers):
		var h_log = h_base + (float(l) / log_layers) * h_wall
		draw_line(iso(-w_hut, 0, h_log), iso(0, d_hut, h_log), LOG_BARK_SHADE.darkened(0.2), 1.2)
		draw_line(iso(0, d_hut, h_log), iso(w_hut, 0, h_log), LOG_BARK_SHADE.darkened(0.3), 1.2)

	# Kapı
	var door_w = 5.0
	var door_h = 10.0
	var door_pos = iso(-3.0, d_hut * 0.8, h_base)
	draw_rect(Rect2(door_pos.x - door_w * 0.5, door_pos.y - door_h, door_w, door_h), DOOR_DARK)

	# 4. Ahşap Beşik Çatı
	var overhang = 2.5
	var h_apex = h_base + h_wall + 13.0
	var apex_f = iso(0, d_hut + overhang, h_apex)
	var apex_b = iso(0, -d_hut - overhang, h_apex)
	
	var r_l_f = iso(-w_hut - overhang, 0, h_base + h_wall - 1.0)
	var r_r_f = iso(w_hut + overhang, 0, h_base + h_wall - 1.0)
	var r_l_b = iso(-w_hut - overhang, -d_hut, h_base + h_wall - 1.0)
	var r_r_b = iso(w_hut + overhang, -d_hut, h_base + h_wall - 1.0)
	
	draw_colored_polygon(PackedVector2Array([r_l_f, apex_f, apex_b, r_l_b]), ROOF_WOOD_LIGHT)
	draw_colored_polygon(PackedVector2Array([apex_f, r_r_f, r_r_b, apex_b]), ROOF_WOOD)
	draw_colored_polygon(PackedVector2Array([r_l_f, r_r_f, apex_f]), LOG_BARK_SHADE)
	draw_line(r_l_f, apex_f, WOOD_PLANK, 2.0)
	draw_line(r_r_f, apex_f, WOOD_PLANK, 2.0)
	draw_line(apex_f, apex_b, WOOD_PLANK.lightened(0.1), 2.0)

	# 5. İstifli Kütükler
	var pile_base = Vector2(-19.0, 6.0)
	_draw_log(pile_base.x, pile_base.y, 0.0, 10.0)
	_draw_log(pile_base.x + 4.0, pile_base.y + 4.0, 0.0, 10.0)
	_draw_log(pile_base.x + 2.0, pile_base.y + 2.0, 4.5, 9.0)

	# 6. Kütük ve Balta
	var stump_pos = Vector2(16.0, 12.0)
	_draw_stump_with_axe(stump_pos.x, stump_pos.y)

func _draw_log(x: float, z: float, h: float, length: float) -> void:
	var rad = 2.5
	var p_start = iso(x, z, h)
	var p_end = iso(x + length * 0.7, z - length * 0.5, h)
	draw_line(p_start, p_end, LOG_BARK, rad * 2.0)
	draw_circle(p_start, rad, LOG_CORE)
	draw_circle(p_start, rad * 0.5, LOG_CORE.darkened(0.15))

func _draw_stump_with_axe(x: float, z: float) -> void:
	var stump_rad = 4.5
	var stump_h = 7.0
	var bot = iso(x, z, 0)
	var top = iso(x, z, stump_h)
	draw_line(bot, top, LOG_BARK_SHADE, stump_rad * 2.0)
	draw_circle(top, stump_rad, LOG_CORE)
	
	var axe_blade_pos = top + Vector2(0, -1.0)
	var axe_handle_top = axe_blade_pos + Vector2(8.0, -11.0)
	draw_line(axe_blade_pos, axe_handle_top, AXE_HANDLE, 2.0)
	
	var blade_pts = PackedVector2Array([
		axe_blade_pos + Vector2(-3, -2),
		axe_blade_pos + Vector2(1, -4),
		axe_blade_pos + Vector2(2, 0),
		axe_blade_pos + Vector2(-2, 2)
	])
	draw_colored_polygon(blade_pts, AXE_METAL)
