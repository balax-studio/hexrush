class_name Bakery
extends Node2D

## Fırın (Tier 3 Çayır Üretim Binası).
## Un (🌾) ve Gıda (🥡) işleyerek yüksek karlı Ekmek (🍞) üretir.

@export var level: int = 1
@export var base_rate: float = 0.25
@export var y_scale: float = 0.85
@export var grid_coord: Vector2i = Vector2i.ZERO

var accumulated_bread: float = 0.0
var max_capacity: float = 20.0
var upgrade_cost_flour: int = 8
var upgrade_cost_food: int = 10
var is_adjacent_to_windmill: bool = false

var _smoke_time: float = 0.0

func _ready() -> void:
	update_stats()

func _process(delta: float) -> void:
	_smoke_time += delta * 3.0
	queue_redraw()

func update_stats() -> void:
	max_capacity = (base_rate * pow(1.5, level - 1)) * 40.0
	upgrade_cost_flour = int(8 * pow(1.35, level - 1))
	upgrade_cost_food = int(10 * pow(1.35, level - 1))

func upgrade() -> void:
	level += 1
	update_stats()

func collect_bread() -> float:
	var amt = accumulated_bread
	accumulated_bread = 0.0
	return amt

func is_full() -> bool:
	return accumulated_bread >= max_capacity

func _draw() -> void:
	# 1. 3D Taş Fırın Binası
	var stone_color = Color(0.42, 0.44, 0.48)
	var roof_color = Color(0.72, 0.28, 0.22)
	
	# Zemin gölgesi
	var shadow_poly = PackedVector2Array([
		Vector2(-22, 6 * y_scale), Vector2(22, 6 * y_scale),
		Vector2(26, 18 * y_scale), Vector2(-26, 18 * y_scale)
	])
	draw_colored_polygon(shadow_poly, Color(0, 0, 0, 0.35))
	
	# Taş Gövde
	var body_poly = PackedVector2Array([
		Vector2(-18, -12 * y_scale), Vector2(18, -12 * y_scale),
		Vector2(18, 12 * y_scale), Vector2(-18, 12 * y_scale)
	])
	draw_colored_polygon(body_poly, stone_color)
	draw_polyline(body_poly, stone_color.darkened(0.3), 1.5, true)
	
	# Kiremit Çatı
	var roof_poly = PackedVector2Array([
		Vector2(0, -28 * y_scale),
		Vector2(22, -10 * y_scale),
		Vector2(-22, -10 * y_scale)
	])
	draw_colored_polygon(roof_poly, roof_color)
	draw_polyline(roof_poly, roof_color.lightened(0.2), 1.5, true)
	
	# Fırın Ağzı (Sıcak Ateş Parıltısı)
	var door_rect = Rect2(-6, 0, 12, 12 * y_scale)
	draw_rect(door_rect, Color(0.2, 0.1, 0.05))
	draw_circle(Vector2(0, 6 * y_scale), 4.0, Color(1.0, 0.55, 0.15, 0.9))
	
	# Baca ve Tüten Duman
	var chimney_rect = Rect2(8, -32 * y_scale, 6, 14 * y_scale)
	draw_rect(chimney_rect, Color(0.3, 0.32, 0.35))
	
	# Duman halkaları
	for i in range(3):
		var sm_y = -34 * y_scale - (float(i) * 8.0 * y_scale) - sin(_smoke_time + i) * 3.0
		var sm_x = 11.0 + sin(_smoke_time * 0.8 + i * 1.5) * 4.0
		draw_circle(Vector2(sm_x, sm_y), 3.0 + i * 1.2, Color(0.9, 0.9, 0.95, 0.45 - i * 0.12))
	
	# Seviye Rozeti
	if level > 1:
		draw_circle(Vector2(-12, -20 * y_scale), 6.0, Color(1.0, 0.85, 0.2))
		draw_circle(Vector2(-12, -20 * y_scale), 4.5, Color(0.15, 0.15, 0.2))
