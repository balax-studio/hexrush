class_name ScreenShakeController
extends Node

## Ekran Sarsıntısı ve Tokluk Hissi Yöneticisi (Screen Shake & Juice)

@export var camera: Camera2D
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

func _ready() -> void:
	if not camera and get_parent() is Camera2D:
		camera = get_parent() as Camera2D

func trigger_shake(intensity: float = 6.0, duration: float = 0.2) -> void:
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration

func _process(delta: float) -> void:
	if _shake_timer > 0.0 and is_instance_valid(camera):
		_shake_timer -= delta
		var damping: float = _shake_timer / _shake_duration
		var offset_x: float = randf_range(-_shake_intensity, _shake_intensity) * damping
		var offset_y: float = randf_range(-_shake_intensity, _shake_intensity) * damping
		camera.offset = Vector2(offset_x, offset_y)
	elif is_instance_valid(camera) and camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO
