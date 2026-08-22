class_name MountainMine
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu Dağ Madeni ve Taş Ocağı sınıfı.

@export var mine_scale: float = 1.0
@export var y_scale: float = 0.85

var building_type: String = "quarry" # "quarry" veya "mine"
var level: int = 1
var base_rate: float = 0.35
var max_capacity: float = 10.5
var accumulated_resource: float = 0.0
var upgrade_cost_wood: int = 15
var upgrade_cost_plank: int = 8
var upgrade_cost_stone: int = 15

var grid_coord: Vector2i = Vector2i.ZERO
var _time: float = 0.0

const STONE_COLOR = Color(0.58, 0.64, 0.72)
const STONE_DARK = Color(0.28, 0.33, 0.39)
const WOOD_BEAM = Color(0.45, 0.28, 0.16)
const IRON_INGOT = Color(0.85, 0.90, 0.98)
const GLOW_FORGE = Color(0.98, 0.45, 0.15)

func _ready() -> void:
	if building_type == "quarry":
		base_rate = 0.35
	else:
		base_rate = 0.25
	max_capacity = snapped(base_rate * 30.0, 0.1)
	
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * mine_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.0
	queue_redraw()

func collect_resource() -> float:
	var collected = accumulated_resource
	accumulated_resource = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mine_scale * 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * mine_scale, 0.2)
	
	return collected

func upgrade() -> void:
	level += 1
	base_rate = snapped(base_rate * 1.5, 0.01)
	max_capacity = snapped(base_rate * 30.0, 0.1)
	upgrade_cost_wood = int(round(upgrade_cost_wood * 1.6)) + 2
	upgrade_cost_plank = int(round(upgrade_cost_plank * 1.6)) + 1
	upgrade_cost_stone = int(round(upgrade_cost_stone * 1.6)) + 2
	
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (mine_scale * 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * mine_scale, 0.3)

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Zemin Tabanı
	var p_fl = iso(-18, 0, 0)
	var p_ff = iso(0, 14, 0)
	var p_fr = iso(18, 0, 0)
	var p_fb = iso(0, -14, 0)
	draw_colored_polygon(PackedVector2Array([p_fl, p_ff, p_fr, p_fb]), STONE_DARK)

	if building_type == "quarry":
		# Taş Ocağı Vinç / Çıkrık
		var base_beam_b = iso(-14, -6, 0)
		var base_beam_t = iso(-14, -6, 22)
		draw_line(base_beam_b, base_beam_t, WOOD_BEAM, 3.5)
		draw_line(base_beam_t, iso(2, -4, 20), WOOD_BEAM, 2.5)
		
		# Halat & Yontulmuş Taş
		var sway = sin(_time * 1.5) * 2.0
		var hook_top = iso(2, -4, 20)
		var hook_bottom = iso(2 + sway, -4, 8)
		draw_line(hook_top, hook_bottom, Color.WHITE, 1.2)
		draw_rect(Rect2(hook_bottom.x - 4, hook_bottom.y - 4, 8, 8), STONE_COLOR)
	else:
		# Demir Madeni Tünel Girişi
		var tunnel_poly = PackedVector2Array([
			iso(-10, 0, 0),
			iso(10, 0, 0),
			iso(8, 0, 16),
			iso(-8, 0, 16)
		])
		draw_colored_polygon(tunnel_poly, Color(0.08, 0.10, 0.14))
		draw_line(iso(-10, 0, 0), iso(-10, 0, 18), WOOD_BEAM, 3.0)
		draw_line(iso(10, 0, 0), iso(10, 0, 18), WOOD_BEAM, 3.0)
		draw_line(iso(-12, 0, 18), iso(12, 0, 18), WOOD_BEAM, 3.5)
		
		# Döküm Ocağı Ateşi
		var glow_pulse = sin(_time * 4.0) * 1.5
		draw_circle(iso(14, -4, 4), 4.0 + glow_pulse, GLOW_FORGE)
