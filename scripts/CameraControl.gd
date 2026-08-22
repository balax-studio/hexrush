class_name CameraControl
extends Camera2D

## Mobil dokunmatik sürükleme (pan) ve yakınlaştırma (zoom) sağlayan kamera sistemi.

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.1
@export var drag_damping: float = 10.0

var _is_dragging: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO
var _touch_points: Dictionary = {}
var _last_touch_dist: float = 0.0

func _ready() -> void:
	zoom = Vector2(1.0, 1.0)
	position = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# Fare tekerleği zoom desteği
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by_factor(1.0 - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by_factor(1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_dragging = event.pressed
			_drag_start_pos = event.position

	# Fare ile haritayı sürükleme
	elif event is InputEventMouseMotion and _is_dragging:
		position -= (event.relative / zoom.x)

	# Mobil dokunmatik (Tek parmakla sürükle, çift parmakla zoom)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
			_last_touch_dist = 0.0

	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		if _touch_points.size() == 1:
			position -= (event.relative / zoom.x)
		elif _touch_points.size() == 2:
			var p1: Vector2 = _touch_points.values()[0]
			var p2: Vector2 = _touch_points.values()[1]
			var dist = p1.distance_to(p2)
			if _last_touch_dist > 0.0:
				var factor = dist / _last_touch_dist
				zoom_by_factor(factor)
			_last_touch_dist = dist

func zoom_by_factor(factor: float) -> void:
	var new_zoom = clamp(zoom.x * factor, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
