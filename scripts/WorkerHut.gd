class_name WorkerHut
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu Ahşap İşçi Kulübesi, Taş Temel, El Arabası ve Aletler.

@export var hut_scale: float = 1.0
@export var y_scale: float = 0.85

# Seviye ve Otomatik Taşıma Hızı (Transfer Rate)
var level: int = 1
var carry_rate: float = 0.80          # Saniyede komşulardan otomatik taşınan maksimum kaynak
var upgrade_cost: int = 3             # Geliştirme bedeli (Gıda)
var total_gathered: float = 0.0       # Bu kulübenin toplam topladığı kaynak istatistiği

var grid_coord: Vector2i = Vector2i.ZERO
var _time: float = 0.0

# Renk Paleti (Doğal ahşap, taş temel, saman çatı ve metal aletler)
const STONE_BASE = Color(0.55, 0.58, 0.62)
const STONE_SHADE = Color(0.40, 0.42, 0.48)
const WOOD_WALL = Color(0.62, 0.44, 0.28)
const WOOD_WALL_SHADE = Color(0.46, 0.31, 0.18)
const WOOD_BEAM = Color(0.38, 0.24, 0.14)

const ROOF_THATCH = Color(0.88, 0.76, 0.42)      # Saman / Kamış çatı
const ROOF_THATCH_SHADE = Color(0.70, 0.56, 0.28)
const ROOF_RIDGE = Color(0.95, 0.86, 0.55)

const DOOR_DARK = Color(0.24, 0.16, 0.10)
const WINDOW_GLOW = Color(1.0, 0.88, 0.45, 0.85) # Sıcak lamba ışığı
const METAL_COLOR = Color(0.72, 0.75, 0.80)
const WHEEL_WOOD = Color(0.50, 0.34, 0.20)
const SMOKE_COLOR = Color(0.85, 0.88, 0.92, 0.45)

func _ready() -> void:
	# Açılışta topraktan elastik pop-in animasyonuyla belirmesi
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * hut_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.0
	queue_redraw()

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func upgrade() -> void:
	level += 1
	carry_rate = snapped(carry_rate * 1.5, 0.05)
	upgrade_cost = int(round(upgrade_cost * 1.8)) + 1
	
	# Geliştirme animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (hut_scale * 1.15), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * hut_scale, 0.25)

func _draw() -> void:
	# 1. Taş Temel Kaide
	var w_base = 18.0
	var d_base = 15.0
	var h_base = 4.0
	var p_f = iso(0, d_base, 0)
	var p_l = iso(-w_base, 0, 0)
	var p_r = iso(w_base, 0, 0)
	var p_f_top = iso(0, d_base, h_base)
	var p_l_top = iso(-w_base, 0, h_base)
	var p_r_top = iso(w_base, 0, h_base)
	
	draw_colored_polygon(PackedVector2Array([p_l, p_f, p_f_top, p_l_top]), STONE_BASE.lightened(0.1))
	draw_colored_polygon(PackedVector2Array([p_f, p_r, p_r_top, p_f_top]), STONE_BASE)
	draw_line(p_l_top, p_f_top, STONE_SHADE, 1.5)
	draw_line(p_f_top, p_r_top, STONE_SHADE, 1.5)

	# 2. Ahşap Kütük Duvarlar
	var w_wall = 14.0
	var d_wall = 12.0
	var h_wall = 16.0
	var w_f = iso(0, d_wall, h_base)
	var w_l = iso(-w_wall, 0, h_base)
	var w_r = iso(w_wall, 0, h_base)
	var w_f_top = iso(0, d_wall, h_base + h_wall)
	var w_l_top = iso(-w_wall, 0, h_base + h_wall)
	var w_r_top = iso(w_wall, 0, h_base + h_wall)
	
	draw_colored_polygon(PackedVector2Array([w_l, w_f, w_f_top, w_l_top]), WOOD_WALL)
	draw_colored_polygon(PackedVector2Array([w_f, w_r, w_r_top, w_f_top]), WOOD_WALL_SHADE)
	
	# Ahşap Kapı
	var door_w = 6.0
	var door_h = 10.0
	var door_pos = iso(-3.0, d_wall * 0.8, h_base)
	draw_rect(Rect2(door_pos.x - door_w * 0.5, door_pos.y - door_h, door_w, door_h), DOOR_DARK)
	
	# Sıcak Işıklı Pencere
	var win_pos = iso(6.0, d_wall * 0.5, h_base + 6.0)
	draw_rect(Rect2(win_pos.x - 2.5, win_pos.y - 2.5, 5.0, 5.0), WINDOW_GLOW)
	draw_line(Vector2(win_pos.x - 2.5, win_pos.y), Vector2(win_pos.x + 2.5, win_pos.y), WOOD_BEAM, 1.0)
	draw_line(Vector2(win_pos.x, win_pos.y - 2.5), Vector2(win_pos.x, win_pos.y + 2.5), WOOD_BEAM, 1.0)

	# 3. Saman Beşik Çatı
	var overhang = 3.0
	var h_apex = h_base + h_wall + 14.0
	var apex_f = iso(0, d_wall + overhang, h_apex)
	var apex_b = iso(0, -d_wall - overhang, h_apex)
	var r_l_f = iso(-w_wall - overhang, 0, h_base + h_wall - 1.0)
	var r_r_f = iso(w_wall + overhang, 0, h_base + h_wall - 1.0)
	var r_l_b = iso(-w_wall - overhang, -d_wall, h_base + h_wall - 1.0)
	var r_r_b = iso(w_wall + overhang, -d_wall, h_base + h_wall - 1.0)
	
	draw_colored_polygon(PackedVector2Array([r_l_f, apex_f, apex_b, r_l_b]), ROOF_THATCH)
	draw_colored_polygon(PackedVector2Array([apex_f, r_r_f, r_r_b, apex_b]), ROOF_THATCH_SHADE)
	draw_line(apex_f, apex_b, ROOF_RIDGE, 2.5)

	# 4. Taş Baca ve Duman
	var ch_x = 7.0
	var ch_z = -4.0
	var ch_bot = iso(ch_x, ch_z, h_base + h_wall + 4.0)
	var ch_top = iso(ch_x, ch_z, h_base + h_wall + 18.0)
	draw_line(ch_bot, ch_top, STONE_BASE, 4.0)
	draw_line(ch_top + Vector2(-2, 0), ch_top + Vector2(2, 0), STONE_SHADE, 2.0)
	
	for s in range(3):
		var st = fmod(_time * 0.8 + float(s) * 0.33, 1.0)
		var sm_pos = ch_top + Vector2(sin(st * 4.0) * 4.0 - st * 8.0, -st * 20.0)
		var sm_rad = 2.0 + st * 4.0
		var sm_col = SMOKE_COLOR
		sm_col.a = (1.0 - st) * 0.5
		draw_circle(sm_pos, sm_rad, sm_col)

	# 5. El Arabası
	var cart_pos = Vector2(-15.0, 10.0)
	_draw_wheelbarrow(cart_pos.x, cart_pos.y)

func _draw_wheelbarrow(x: float, z: float) -> void:
	var b_pos = iso(x, z, 0.0)
	draw_circle(b_pos + Vector2(-4, -2), 3.0, WHEEL_WOOD)
	draw_line(b_pos + Vector2(-4, -2), b_pos + Vector2(6, -6), WOOD_WALL, 2.0)
	draw_line(b_pos + Vector2(0, -3), b_pos + Vector2(5, 0), WOOD_WALL_SHADE, 1.5)
	
	var box_pts = PackedVector2Array([
		b_pos + Vector2(-4, -5),
		b_pos + Vector2(3, -9),
		b_pos + Vector2(5, -6),
		b_pos + Vector2(-2, -2)
	])
	draw_colored_polygon(box_pts, WOOD_WALL.lightened(0.1))
	draw_line(b_pos + Vector2(6, -6), b_pos + Vector2(10, -8), WOOD_BEAM, 1.8)
