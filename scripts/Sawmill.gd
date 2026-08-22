class_name Sawmill
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu Kereste Fabrikası, Dönen Hızar Testeresi, Kereste Sundurması ve İstifli Kalaslar.

@export var mill_scale: float = 1.0
@export var y_scale: float = 0.85

const FILL_DURATION: float = 30.0

var level: int = 1
var base_rate: float = 0.20           # Tam hızda saniyede 0.20 🪵 Kereste üretimi
var max_capacity: float = 6.00        # 30 sn x 0.20 = 6.00 🪵 Kereste kapasite tavanı
var accumulated_plank: float = 0.0    # Fabrikada biriken kereste miktarı
var upgrade_cost_food: int = 4
var upgrade_cost_wood: int = 6

var grid_coord: Vector2i = Vector2i.ZERO
var is_adjacent_to_lumberjack: bool = false # Komşu oduncudan doğrudan çekiyorsa %100 hız
var _time: float = 0.0
var _saw_angle: float = 0.0

# Renk Paleti
const STONE_DARK = Color(0.40, 0.42, 0.46)
const TIMBER_FRAME = Color(0.45, 0.28, 0.16)
const PLANK_LIGHT = Color(0.88, 0.72, 0.48)       # İşlenmiş düzgün sarı kereste
const PLANK_SHADE = Color(0.70, 0.54, 0.32)
const SAW_BLADE = Color(0.85, 0.88, 0.94)
const SAW_TEETH = Color(0.95, 0.98, 1.0)
const ROOF_WOOD = Color(0.32, 0.20, 0.12)
const CHIPS_COLOR = Color(0.95, 0.85, 0.60)

func _ready() -> void:
	max_capacity = snapped(base_rate * FILL_DURATION, 0.1)
	
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.0
	_saw_angle += delta * 6.0 # Hızlı dönen testere
	queue_redraw()

func is_full() -> bool:
	return accumulated_plank >= (max_capacity - 0.01)

func collect_plank() -> float:
	var collected = accumulated_plank
	accumulated_plank = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mill_scale * 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.2)
	
	return collected

func upgrade() -> void:
	level += 1
	base_rate = snapped(base_rate * 1.5, 0.01)
	max_capacity = snapped(base_rate * FILL_DURATION, 0.1)
	upgrade_cost_food = int(round(upgrade_cost_food * 1.8)) + 1
	upgrade_cost_wood = int(round(upgrade_cost_wood * 1.8)) + 2
	
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mill_scale * 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.3)

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Zemin Talaşları ve Taş Temel
	var p_fl = iso(-18, 0, 0)
	var p_ff = iso(0, 14, 0)
	var p_fr = iso(18, 0, 0)
	var p_fb = iso(0, -14, 0)
	draw_colored_polygon(PackedVector2Array([p_fl, p_ff, p_fr, p_fb]), STONE_DARK)

	# 2. Ahşap Çatı Kolonları / Sundurma Direkleri
	var col_h = 16.0
	var col_pts = [
		Vector2(-14, -10), Vector2(14, -10),
		Vector2(-14, 10), Vector2(14, 10)
	]
	for cp in col_pts:
		var b = iso(cp.x, cp.y, 0)
		var t = iso(cp.x, cp.y, col_h)
		draw_line(b, t, TIMBER_FRAME, 3.0)

	# 3. Dönen Büyük Çelik Hızar Testeresi (Saw Blade)
	var saw_center = iso(0, 2.0, 8.0)
	var saw_rad = 9.0
	draw_circle(saw_center, saw_rad, SAW_BLADE)
	draw_circle(saw_center, 3.0, TIMBER_FRAME)
	
	# Testere dişleri çizgileri
	for t in range(6):
		var ang = _saw_angle + float(t) * (PI / 3.0)
		var p1 = saw_center + Vector2(cos(ang) * (saw_rad - 2.0), sin(ang) * (saw_rad - 2.0) * y_scale)
		var p2 = saw_center + Vector2(cos(ang) * (saw_rad + 2.5), sin(ang) * (saw_rad + 2.5) * y_scale)
		draw_line(p1, p2, SAW_TEETH, 1.8)

	# 4. Sundurma Çatısı (Timber Shed Roof)
	var roof_h = col_h + 8.0
	var r_l = iso(-17, 0, col_h + 3.0)
	var r_r = iso(17, 0, col_h + 3.0)
	var r_apex = iso(0, 0, roof_h)
	var r_b_apex = iso(0, -14, roof_h)
	
	draw_colored_polygon(PackedVector2Array([r_l, r_apex, r_b_apex, iso(-17, -14, col_h + 3.0)]), ROOF_WOOD.lightened(0.1))
	draw_colored_polygon(PackedVector2Array([r_apex, r_r, iso(17, -14, col_h + 3.0), r_b_apex]), ROOF_WOOD)

	# 5. İstiflenmiş Kusursuz Kereste Kalasları (Stack of Planks)
	_draw_plank_stack(-12.0, 10.0)
	_draw_plank_stack(10.0, 10.0)

func _draw_plank_stack(x: float, z: float) -> void:
	for layer in range(3):
		var h = float(layer) * 3.0
		var p1 = iso(x - 5.0, z, h)
		var p2 = iso(x + 5.0, z, h)
		var p1_top = iso(x - 5.0, z, h + 2.0)
		var p2_top = iso(x + 5.0, z, h + 2.0)
		draw_line(p1, p2, PLANK_SHADE, 3.0)
		draw_line(p1_top, p2_top, PLANK_LIGHT, 2.5)
