class_name Windmill
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu Taş Değirmen, Dönen 4 Kanat, Ahşap Koni Çatı ve Un Çuvalları.

@export var mill_scale: float = 1.0
@export var y_scale: float = 0.85

const FILL_DURATION: float = 30.0

var level: int = 1
var base_rate: float = 0.25           # Tam hızda saniyede 0.25 🌾 Un üretimi
var max_capacity: float = 7.50        # 30 sn x 0.25 = 7.50 🌾 Un kapasite tavanı
var accumulated_flour: float = 0.0    # Değirmende biriken un
var upgrade_cost_food: int = 5        # Geliştirme bedeli
var upgrade_cost_wood: int = 4

var grid_coord: Vector2i = Vector2i.ZERO
var is_adjacent_to_farm: bool = false # Komşu tarladan doğrudan çekiyorsa %100 hız
var _time: float = 0.0
var _blade_angle: float = 0.0

# Renk Paleti (Doğal taş kule, ahşap kanatlar, beyaz yelken bezi ve un çuvalları)
const STONE_LIGHT = Color(0.85, 0.86, 0.89)
const STONE_DARK = Color(0.60, 0.62, 0.68)
const ROOF_WOOD = Color(0.48, 0.32, 0.18)
const ROOF_WOOD_LIGHT = Color(0.62, 0.42, 0.24)
const BLADE_WOOD = Color(0.35, 0.22, 0.12)
const SAIL_CLOTH = Color(0.95, 0.95, 0.92, 0.9)
const FLOUR_SACK = Color(0.92, 0.88, 0.78)
const FLOUR_POWDER = Color(1.0, 1.0, 0.95)
const DOOR_WOOD = Color(0.30, 0.18, 0.10)

func _ready() -> void:
	max_capacity = snapped(base_rate * FILL_DURATION, 0.1)
	
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 2.5
	# Kanat dönüşü
	_blade_angle += delta * 1.8
	queue_redraw()

## Kapasitenin dolup dolmadığını döndürür
func is_full() -> bool:
	return accumulated_flour >= (max_capacity - 0.01)

## Biriken unu hasat eder ve miktarını döndürür
func collect_flour() -> float:
	var collected = accumulated_flour
	accumulated_flour = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mill_scale * 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.2)
	
	return collected

func upgrade() -> void:
	level += 1
	base_rate = snapped(base_rate * 1.5, 0.01)
	max_capacity = snapped(base_rate * FILL_DURATION, 0.1)
	upgrade_cost_food = int(round(upgrade_cost_food * 1.8)) + 2
	upgrade_cost_wood = int(round(upgrade_cost_wood * 1.8)) + 1
	
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mill_scale * 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * mill_scale, 0.3)

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Zemin Un Çuvalları
	_draw_flour_sacks(-16.0, 8.0)
	
	# 2. Silindirik / Sekizgen Taş Değirmen Gövdesi
	var rad_bot = 15.0
	var rad_top = 11.0
	var h_tower = 26.0
	
	var bot_l = iso(-rad_bot, 0, 0)
	var bot_f = iso(0, rad_bot * 0.8, 0)
	var bot_r = iso(rad_bot, 0, 0)
	
	var top_l = iso(-rad_top, 0, h_tower)
	var top_f = iso(0, rad_top * 0.8, h_tower)
	var top_r = iso(rad_top, 0, h_tower)
	
	# Sol aydınlık cephe
	draw_colored_polygon(PackedVector2Array([bot_l, bot_f, top_f, top_l]), STONE_LIGHT)
	# Sağ gölgeli cephe
	draw_colored_polygon(PackedVector2Array([bot_f, bot_r, top_r, top_f]), STONE_DARK)
	
	# Ahşap Kapı
	var door_w = 6.0
	var door_h = 11.0
	var dp = iso(-2.0, rad_bot * 0.7, 0)
	draw_rect(Rect2(dp.x - door_w * 0.5, dp.y - door_h, door_w, door_h), DOOR_WOOD)
	
	# 3. Ahşap Koni Kubbe Çatı
	var h_apex = h_tower + 14.0
	var apex = iso(0, 0, h_apex)
	draw_colored_polygon(PackedVector2Array([top_l, apex, top_f]), ROOF_WOOD_LIGHT)
	draw_colored_polygon(PackedVector2Array([top_f, apex, top_r]), ROOF_WOOD)
	draw_line(top_f, apex, BLADE_WOOD, 2.0)
	
	# 4. Değirmen Göbeği ve Dönen 4 Yelkenli Kanat
	var hub_pos = iso(0, rad_top * 0.85, h_tower - 2.0)
	draw_circle(hub_pos, 3.0, BLADE_WOOD)
	
	var blade_len = 24.0
	for i in range(4):
		var ang = _blade_angle + float(i) * (PI * 0.5)
		var bx = cos(ang) * blade_len
		var by = sin(ang) * blade_len * y_scale
		var tip = hub_pos + Vector2(bx, by)
		
		# Ahşap kiriş kolu
		draw_line(hub_pos, tip, BLADE_WOOD, 2.5)
		
		# Yelken kumaşı
		var sail_w = 6.0
		var sail_dir = Vector2(-sin(ang), cos(ang) * y_scale).normalized() * sail_w
		var s_mid = hub_pos.lerp(tip, 0.25)
		var sail_poly = PackedVector2Array([
			s_mid,
			tip,
			tip + sail_dir,
			s_mid + sail_dir * 0.7
		])
		draw_colored_polygon(sail_poly, SAIL_CLOTH)
		draw_polyline(sail_poly, BLADE_WOOD.darkened(0.2), 1.0)

func _draw_flour_sacks(x: float, z: float) -> void:
	var p1 = iso(x, z, 0)
	var p2 = iso(x + 4.0, z + 3.0, 0)
	var p3 = iso(x + 2.0, z + 1.0, 4.0)
	
	draw_circle(p1, 4.0, FLOUR_SACK)
	draw_circle(p2, 4.0, FLOUR_SACK.darkened(0.1))
	draw_circle(p3, 3.5, FLOUR_SACK.lightened(0.08))
	draw_circle(p3 + Vector2(0, 1), 1.5, FLOUR_POWDER)
