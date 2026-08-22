class_name Bridge
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu, ahşap kazıklı ve korkuluklu Köprü yapısı.

@export var bridge_scale: float = 1.0
@export var y_scale: float = 0.85

var grid_coord: Vector2i = Vector2i.ZERO

# Renk Paleti
const WOOD_PLANK = Color(0.68, 0.48, 0.32)
const WOOD_DARK = Color(0.48, 0.30, 0.18)
const WOOD_LIGHT = Color(0.82, 0.62, 0.42)
const PILLAR_COLOR = Color(0.38, 0.24, 0.14)
const WATER_SHADOW = Color(0.08, 0.18, 0.28, 0.45)

func _ready() -> void:
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * bridge_scale, 0.6)

func _draw() -> void:
	# 1. Su üzerindeki gölge
	draw_circle(Vector2(2.0, 3.0 * y_scale), 26.0 * y_scale, WATER_SHADOW)
	
	# 2. Suya çakılı 4 ana ahşap kazık (Pillars)
	var pillars = [
		Vector2(-22.0, -10.0 * y_scale),
		Vector2(22.0, -10.0 * y_scale),
		Vector2(-22.0, 10.0 * y_scale),
		Vector2(22.0, 10.0 * y_scale)
	]
	
	for p in pillars:
		draw_rect(Rect2(p.x - 2.5, p.y - 6.0 * y_scale, 5.0, 12.0 * y_scale), PILLAR_COLOR)
		draw_circle(Vector2(p.x, p.y + 6.0 * y_scale), 3.0 * y_scale, Color(0.2, 0.4, 0.6, 0.3))
		
	# 3. Ana Ahşap Platform (Yatay kalaslar)
	var num_planks = 7
	var bridge_w = 46.0
	var bridge_h = 24.0 * y_scale
	
	for i in range(num_planks):
		var t = float(i) / float(num_planks - 1)
		var x_pos = lerp(-bridge_w * 0.5, bridge_w * 0.5, t)
		var plank_rect = Rect2(x_pos - 2.5, -bridge_h * 0.5, 4.5, bridge_h)
		draw_rect(plank_rect, WOOD_LIGHT if i % 2 == 0 else WOOD_PLANK)
		draw_rect(plank_rect, WOOD_DARK, false, 1.0)
		
	# 4. Yan Güvenlik Korkulukları (Railing)
	draw_line(Vector2(-bridge_w * 0.5, -bridge_h * 0.5 - 4.0 * y_scale), Vector2(bridge_w * 0.5, -bridge_h * 0.5 - 4.0 * y_scale), WOOD_DARK, 2.5)
	draw_line(Vector2(-bridge_w * 0.5, bridge_h * 0.5 - 1.0 * y_scale), Vector2(bridge_w * 0.5, bridge_h * 0.5 - 1.0 * y_scale), WOOD_DARK, 2.5)
	
	# Korkuluk dikey dikmeleri
	for i in range(4):
		var t = float(i) / 3.0
		var x_pos = lerp(-bridge_w * 0.45, bridge_w * 0.45, t)
		draw_line(Vector2(x_pos, -bridge_h * 0.5), Vector2(x_pos, -bridge_h * 0.5 - 6.0 * y_scale), WOOD_LIGHT, 2.0)
		draw_line(Vector2(x_pos, bridge_h * 0.5 - 3.0 * y_scale), Vector2(x_pos, bridge_h * 0.5 + 2.0 * y_scale), WOOD_LIGHT, 2.0)
