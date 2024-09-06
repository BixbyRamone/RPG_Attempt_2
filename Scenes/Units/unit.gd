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
@export var h_frame: int
@export var move_range: int
@export var move_speed: float = 100.0
@export var stats: Stats
@export var ability: Resource
@export var active_behavior_state: State

signal walk_finished
signal select_unit
signal destination

var tilemap: Level
#var gameboard: GameBoard
var saved_flooded_tiles: Array = []
var has_moved: bool = false
var move_distance: int = 0

@onready var fsm: FiniteStateMachine = $UnitFiniteStateMachine
@onready var static_behavior: State = $UnitFiniteStateMachine/StaticBehavior


@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path: Path2D = $Path2D
@onready var _path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var _sprite: Sprite2D = $Path2D/PathFollow2D/Sprite2D
@onready var _status_icon: Sprite2D = $Path2D/PathFollow2D/Sprite2D/StatusIcon

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
var gameboard: GameBoard:
	set(value):
		active_behavior_state.gameboard = value
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	active_behavior_state.signal_dest_to_unit.connect(signal_dest_to_board)
	_anim_player.play("Idle")
	move_range = stats.move
	_sprite.texture = stats.skin
	_sprite.skin_hframes = stats.skin_hframes
	_sprite.frame = h_frame
	tilemap = get_tree().get_first_node_in_group("Level")
	if not Engine.is_editor_hint():
		_path.curve = Curve2D.new()
	if active_behavior_state != null:
		active_behavior_state.identity = h_frame
	if stats.owner == "Resource":
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		_sprite.frame = rng.randi_range(0, _sprite.hframes - 1)

func _process(delta: float) -> void:
	_path_follow.progress_ratio += move_speed * delta
	
	if _path_follow.progress_ratio >= 1.0:
		self.is_walking = false
		_path_follow.progress_ratio = 0.0
		position = tilemap.return_pixel_pos_from_grid(cell)
		_path.curve.clear_points()
		has_moved = true
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

func activate(flooded_tiles: Array) -> void:
	active_behavior_state.tiles_to_choose = flooded_tiles
	active_behavior_state.tilemap = tilemap
	fsm.change_state(active_behavior_state)

func signal_dest_to_board(signal_cell: Vector2i) -> void:
	destination.emit(signal_cell)

func set_status_icon() -> void:
	_status_icon.frame = stats.status_array.find(stats.status)

func show_attack_status(status_int: int) -> void:
	_status_icon.frame = status_int
