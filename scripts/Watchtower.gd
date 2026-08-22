class_name Watchtower
extends Node2D

## 3 Boyutlu İzometrik Gözcü Kulesi (Watchtower)
## Gece akıncılarına karşı ok yağmuru savunması ve meşale ışığı sağlar.

@export var tower_scale: float = 1.0
@export var y_scale: float = 0.85

var level: int = 1
var defense_power: int = 25
var grid_coord: Vector2i = Vector2i.ZERO
var _time: float = 0.0

const WOOD_DARK = Color(0.35, 0.22, 0.12)
const WOOD_BEAM = Color(0.55, 0.35, 0.20)
const ROOF_THATCH = Color(0.78, 0.62, 0.35)
const TORCH_FIRE = Color(0.98, 0.45, 0.15)
const BANNER_RED = Color(0.85, 0.20, 0.20)

func _ready() -> void:
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * tower_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.0
	queue_redraw()

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Zemin Tabanı & Taş Temel
	var p_fl = iso(-14, 0, 0)
	var p_ff = iso(0, 10, 0)
	var p_fr = iso(14, 0, 0)
	var p_fb = iso(0, -10, 0)
	draw_colored_polygon(PackedVector2Array([p_fl, p_ff, p_fr, p_fb]), Color(0.25, 0.28, 0.32))

	# 2. 4 Ana Ahşap Kule Direği (Tower Timber Columns)
	var post_h = 32.0
	var posts = [Vector2(-8, -6), Vector2(8, -6), Vector2(-8, 6), Vector2(8, 6)]
	for p in posts:
		draw_line(iso(p.x, p.y, 0), iso(p.x, p.y, post_h), WOOD_DARK, 3.2)

	# Çapraz Destek Kirişleri
	draw_line(iso(-8, 6, 4), iso(8, 6, 28), WOOD_BEAM, 1.8)
	draw_line(iso(-8, 6, 28), iso(8, 6, 4), WOOD_BEAM, 1.8)

	# 3. Üst Gözetleme Platformu (Lookout Deck)
	var deck_poly = PackedVector2Array([
		iso(-12, 0, post_h),
		iso(0, 8, post_h),
		iso(12, 0, post_h),
		iso(0, -8, post_h)
	])
	draw_colored_polygon(deck_poly, WOOD_BEAM)

	# 4. Sivri Sazlık Çatı (Pitched Thatched Roof)
	var roof_poly_left = PackedVector2Array([
		iso(-14, 0, post_h + 8),
		iso(0, 9, post_h + 8),
		iso(0, 0, post_h + 24)
	])
	var roof_poly_right = PackedVector2Array([
		iso(0, 9, post_h + 8),
		iso(14, 0, post_h + 8),
		iso(0, 0, post_h + 24)
	])
	draw_colored_polygon(roof_poly_left, ROOF_THATCH.darkened(0.15))
	draw_colored_polygon(roof_poly_right, ROOF_THATCH)

	# 5. Gece Nöbet Meşalesi / Kor Ateş Parıltısı
	var flame_flicker = sin(_time * 6.0) * 1.5
	var torch_pos = iso(10, 6, post_h + 4)
	draw_circle(torch_pos, 4.0 + flame_flicker, TORCH_FIRE)
	draw_circle(torch_pos, 2.0, Color.YELLOW)

	# 6. Dalgalanan Kraliyet Bayrağı
	var banner_top = iso(0, 0, post_h + 24)
	var flag_wave = sin(_time * 3.5) * 3.0
	draw_line(banner_top, banner_top + Vector2(0, -8), Color.WHITE, 1.5)
	draw_colored_polygon(PackedVector2Array([
		banner_top + Vector2(0, -8),
		banner_top + Vector2(8 + flag_wave, -5),
		banner_top + Vector2(0, -2)
	]), BANNER_RED)
