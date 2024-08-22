@tool
extends Node2D
class_name Unit

const DIRECTIONS = [
	Vector2i(1, 0),  # Right
	Vector2i(-1, 0), # Left
	Vector2i(0, 1),  # Down
	Vector2i(0, -1)  # Up
]
#@export var grid: Resource = preload("res://Resources/Grid.tres")
@export var move_range: int
@export var move_speed: float = 100.0
@export var stats: Resource

signal walk_finished

var tilemap: Level
var gameboard: GameBoard

@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path: Path2D = $Path2D
@onready var _path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var _sprite: Sprite2D = $Path2D/PathFollow2D/Sprite2D

var cell := Vector2i.ZERO :
	set(value):
		cell = value
	get:
		return cell

var is_selected: bool = false:
	set(value):
		is_selected = value
		if is_selected:
			_anim_player.play("Selected")
		else:
			_anim_player.play("Idle")
	get:
		return is_selected
var is_walking: bool = false:
	set(value):
		is_walking = value
		set_process(is_walking)

# Called when the node enters the scene tree for the first time.
func _ready():
	_anim_player.play("Idle")
	move_range = stats.move
	_sprite.texture = stats.skin
	_sprite.skin_hframes = stats.skin_hframes
	set_process(false)
	tilemap = get_tree().get_first_node_in_group("Level")
	if not Engine.is_editor_hint():
		_path.curve = Curve2D.new()

func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta
	
	if _path_follow.progress_ratio >= 1.0:
		self.is_walking = false
		_path_follow.progress_ratio = 0.0
		position = tilemap.return_pixel_pos_from_grid(cell)
		_path.curve.clear_points()
		walk_finished.emit()

func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	_path.curve.add_point(Vector2.ZERO)
	for point in path:
		_path.curve.add_point(tilemap.return_pixel_pos_from_grid(point) - position)
	cell = path[-1]
	self.is_walking = true
		
func unit_return_flood() -> Array:
	var result: Array = []
	var queue: Array = [cell]
	var visited: Dictionary = {}
	
	while not queue.is_empty():
		var current: Vector2i = queue.pop_back()
		
		#if not 
		if current in result:
			continue
		
		var difference: Vector2i = abs(current - cell)
		var distance := int(difference.x + difference.y)
		if distance > move_range:
			continue
		
		result.append(current)
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if gameboard.is_occupied(coordinates):
				continue
			if tilemap.check_tile_status(coordinates) == false:
				continue
			if coordinates in result:
				continue
			
			queue.append(coordinates)
			
	return result


