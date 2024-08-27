extends Camera2D

const directions_y = [Vector2.UP, Vector2.DOWN]
const directions_x = [Vector2.LEFT, Vector2.RIGHT]
@export var camera_body: PlayerCameraBody
var zoom_step: Vector2 = Vector2(0.5, 0.5)
var zoom_speed: float = 0.07
var margin: float = 0.08

@onready var viewport_size = get_viewport().size
@onready var thresholds: Dictionary = {
	Vector2.LEFT: viewport_size.x * margin,
	Vector2.RIGHT: viewport_size.x - (viewport_size.x * margin),
	Vector2.UP: viewport_size.y * margin,
	Vector2.DOWN: viewport_size.y - (viewport_size.y * margin)
}

func _ready() -> void:
	#viewport_size = get_viewport_rect().size
	get_tree().root.connect("size_changed", _on_veiwport_size_changed)
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("zoom_in"):
		_zoom(1)
	if Input.is_action_just_pressed("zoom_out"):
		_zoom(-1)
	if Input.is_action_just_pressed("ui_accept"):
		position = Vector2.ZERO
	
	_detect_mouse_location()
	
func _on_veiwport_size_changed()-> void:
	pass
	
func _detect_mouse_location() -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var multiplier: float = clamp(0.0, 0.0, 1.0)
	var vec: Vector2 = Vector2.ZERO
	var mouse_move_active: bool = false
	
	if mouse_pos.x < thresholds[Vector2.LEFT]:
		vec += Vector2.LEFT
		multiplier = abs((thresholds[Vector2.LEFT] - mouse_pos.x)/thresholds[Vector2.LEFT])
		mouse_move_active = true
	if mouse_pos.x > thresholds[Vector2.RIGHT]:
		vec += Vector2.RIGHT
		multiplier = abs(thresholds[Vector2.RIGHT] - mouse_pos.x)/ thresholds[Vector2.LEFT]
		mouse_move_active = true
		
	if mouse_pos.y < thresholds[Vector2.UP]:
		vec += Vector2.UP
		multiplier = abs((thresholds[Vector2.UP] - mouse_pos.y)/thresholds[Vector2.UP])
		mouse_move_active = true
	if mouse_pos.y > thresholds[Vector2.DOWN]:
		vec += Vector2.DOWN
		multiplier = abs(thresholds[Vector2.DOWN] - mouse_pos.y)/ thresholds[Vector2.UP]
		mouse_move_active = true
		
	multiplier = clamp(multiplier, 0.0, 1.0)
	if mouse_move_active:
		camera_body.mouse_move(multiplier, vec, mouse_move_active)
	else:
		camera_body.mouse_move_active = mouse_move_active
	
func _zoom(direction_sign: int) -> void:
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", zoom + zoom_step * direction_sign, zoom_speed)
