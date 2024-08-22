extends Node2D
class_name GameBoard

const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

@export var level: PackedScene
#@export var test_unit: PackedScene
var level_instance: Level
var unit_dict: Dictionary = {}
var active_unit: Unit
var walkable_cells: Array = []

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var player_turn_state: PlayerTurnState = $FiniteStateMachine/PlayerTurnState

@onready var _hilight: TileHighlight = $Hilgight_TileMap
@onready var _load_timer: Timer = $Timer
@onready var _unit_path: UnitPath = $Hilgight_TileMap/Arrows
# Called when the node enters the scene tree for the first time.
func _ready():
	level_instance = level.instantiate()
	add_child(level_instance)
	level_instance.connect("tile_selected", tile_clicked)
	#level_instance.connect("initiate", _initiate)
	_hilight.connect("check_cell_clickable", set_highlight_clickable)
	#_hilight.connect("cursor_moved", on_cursor_moved)
	_hilight.connect("signal_attach_board", attach_board_to_highlights)
	_load_timer.start()
	

func _check_dict_for_unit(cell: Vector2i) -> void:
	pass
	
func _initiate() -> void:
	unit_dict = level_instance.return_preplaced_units()
	for unit in unit_dict.values():
		unit.gameboard = self
	
func tile_clicked(cell: Vector2i) -> void:
	if !fsm.state is PlayerTurnState:
		return
	if is_occupied(cell):
		_select_unit(cell)
	#if !is_occupied(cell) and active_unit != null:
		#_deselect_active_unit(cell)
	elif active_unit:
		if active_unit.is_selected:
			_move_active_unit(cell)
#func on_cursor_moved() -> void:
	#if active_unit and active_unit.is_selected:
		#_unit_path.draw()
func reinitialize() -> void:
	unit_dict.clear()
	for child in level_instance.return_preplaced_units():
		var unit := child as Unit
		if not unit:
			continue
		unit_dict[unit.cell] = unit
	
func set_highlight_clickable(cell: Vector2i) -> void:
	_hilight.set_highlitable(level_instance.check_tile_status(cell))
	if active_unit and active_unit.is_selected:
		_unit_path.draw(active_unit.cell, cell)

func attach_board_to_highlights() -> void:
	_hilight.tile_board = level_instance

func _select_unit(cell: Vector2i) -> void:
	if !unit_dict.has(cell):
		return
	active_unit = unit_dict[cell]
	if !active_unit.is_selected:
		active_unit.is_selected = true
		#need to check if unit belongs to player
		var flood_fill: Array = flood_fill(active_unit.cell, active_unit.move_range)
		walkable_cells = flood_fill
		#flood_fill = level_instance.return_move_array_sans_obstructions(flood_fill)
		_hilight.flood_fill_highlight(flood_fill, active_unit.cell, active_unit.move_range)
	
func _deselect_active_unit(cell: Vector2i) -> void:
	active_unit.is_selected = false
	_hilight.clear_flood_fill()
	_unit_path.stop()

func _clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()

func _move_active_unit(new_cell: Vector2i) -> void:
	if is_occupied(new_cell) or not new_cell in walkable_cells:
		return
	unit_dict.erase(active_unit.cell)
	unit_dict[new_cell] = active_unit
	_deselect_active_unit(new_cell)
	active_unit.walk_along(_unit_path.current_path)
	await active_unit.walk_finished
	_clear_active_unit()
	
func _on_timer_timeout():
	_initiate()

func is_occupied(cell: Vector2i) -> bool:
	return true if unit_dict.has(cell) else false

func flood_fill(cell: Vector2i, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.is_empty():
		var current = stack.pop_back()
		if current in array:
			continue

		var difference: Vector2i = abs(current - cell)
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2i = current + direction
			if is_occupied(coordinates):
				continue
			if level_instance.get_cell_source_id(0, coordinates) == -1:
				continue
			if coordinates in array:
				continue
			stack.append(coordinates)
	array = array_check(array, max_distance, cell)
	return array
	
func array_check(flood_array: Array, max_dist: int, origin: Vector2i) -> Array:
	var pathfinder = PathFinder.new(level_instance, flood_array)
	var erase_array: Array = []
	var i = 0
	for cell in flood_array:
		var path_count = pathfinder.calculate_point_path(origin, cell)
		if path_count.size() > max_dist + 1:
			erase_array.append(cell)
	for cell in erase_array:
		flood_array.erase(cell)
	return flood_array
