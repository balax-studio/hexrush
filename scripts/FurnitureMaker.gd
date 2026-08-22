class_name FurnitureMaker
extends Node2D

## Mobilyacı (Tier 3 Orman Üretim Binası).
## Kereste (🪵) ve Odun (🪵) işleyerek yüksek karlı Mobilya (🪑) üretir.

@export var level: int = 1
@export var base_rate: float = 0.20
@export var y_scale: float = 0.85
@export var grid_coord: Vector2i = Vector2i.ZERO

var accumulated_furniture: float = 0.0
var max_capacity: float = 15.0
var upgrade_cost_plank: int = 8
var upgrade_cost_wood: int = 12
var is_adjacent_to_sawmill: bool = false

var _saw_time: float = 0.0

func _ready() -> void:
	update_stats()

func _process(delta: float) -> void:
	_saw_time += delta * 4.0
	queue_redraw()

func update_stats() -> void:
	max_capacity = (base_rate * pow(1.5, level - 1)) * 40.0
	upgrade_cost_plank = int(8 * pow(1.35, level - 1))
	upgrade_cost_wood = int(12 * pow(1.35, level - 1))

func upgrade() -> void:
	level += 1
	update_stats()

func collect_furniture() -> float:
	var amt = accumulated_furniture
	accumulated_furniture = 0.0
	return amt

func is_full() -> bool:
	return accumulated_furniture >= max_capacity

func _draw() -> void:
	# 1. 3D Marangoz / Mobilya Atölyesi
	var wood_wall_color = Color(0.55, 0.38, 0.22)
	var roof_color = Color(0.25, 0.45, 0.65)
	
	# Zemin gölgesi
	var shadow_poly = PackedVector2Array([
		Vector2(-24, 6 * y_scale), Vector2(24, 6 * y_scale),
		Vector2(28, 18 * y_scale), Vector2(-28, 18 * y_scale)
	])
	draw_colored_polygon(shadow_poly, Color(0, 0, 0, 0.35))
	
	# Ahşap Atölye Gövdesi
	var body_poly = PackedVector2Array([
		Vector2(-20, -10 * y_scale), Vector2(20, -10 * y_scale),
		Vector2(20, 12 * y_scale), Vector2(-20, 12 * y_scale)
	])
	draw_colored_polygon(body_poly, wood_wall_color)
	draw_polyline(body_poly, wood_wall_color.darkened(0.3), 1.5, true)
	
	# Kalas Çatı
	var roof_poly = PackedVector2Array([
		Vector2(-4, -26 * y_scale),
		Vector2(24, -8 * y_scale),
		Vector2(-24, -8 * y_scale)
	])
	draw_colored_polygon(roof_poly, roof_color)
	draw_polyline(roof_poly, roof_color.lightened(0.25), 1.5, true)
	
	# Çalışma Tezgahı ve Sandalye/Masa Simgesi
	var bench_rect = Rect2(-10, 0, 20, 8 * y_scale)
	draw_rect(bench_rect, Color(0.38, 0.24, 0.14))
	
	# Hareketli Testere/Planya Efekti
	var saw_offset = sin(_saw_time) * 3.0
	draw_line(Vector2(-6 + saw_offset, 2 * y_scale), Vector2(6 + saw_offset, 2 * y_scale), Color(0.85, 0.88, 0.92), 2.0)
	
	# Dışarıda İstiflenmiş Mobilya/Kalaslar
	draw_rect(Rect2(12, 4 * y_scale, 8, 6 * y_scale), Color(0.75, 0.55, 0.35))
	
	# Seviye Rozeti
	if level > 1:
		draw_circle(Vector2(-14, -18 * y_scale), 6.0, Color(1.0, 0.85, 0.2))
		draw_circle(Vector2(-14, -18 * y_scale), 4.5, Color(0.15, 0.15, 0.2))
