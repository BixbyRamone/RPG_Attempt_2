extends Node2D
class_name GameBoard

const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

@export var level: PackedScene
#@export var test_unit: PackedScene
var level_instance: Level
var unit_dict: Dictionary = {}
var active_unit: Unit
var saved_active_unit: Unit
var walkable_cells: Array = []

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var player_turn_state: PlayerTurnState = $FiniteStateMachine/PlayerTurnState
@onready var npc_turn_state: NPCTurnState = $FiniteStateMachine/NPCTurnState
@onready var player_ability_state: PlayerAbilityState = $FiniteStateMachine/PlayerAbilityState

@onready var _gametracker: GameTracker = $GameTracker
@onready var _status_label: Label = $Camera2D/Label
@onready var _hilight: TileHighlight = $Hilgight_TileMap
@onready var _npc_delay_timer: Timer = $Timer
@onready var _unit_path: UnitPath = $Hilgight_TileMap/Arrows
@onready var _ability_button: AbilityButton = $Camera2D/AbilityButton
# Called when the node enters the scene tree for the first time.
func _ready():
	_status_label.text = str(_gametracker.player_status)
	npc_turn_state.end_turn.connect(fsm.change_state.bind(player_turn_state))
	player_turn_state.deselect_unit.connect(cancel_active_unit)
	player_ability_state.exit_ability_state.connect(cancel_ability_view)
	_gametracker.new_status_number.connect(change_status_number)
	level_instance = level.instantiate()
	add_child(level_instance)
	level_instance.tile_selected.connect(tile_clicked)
	_hilight.check_cell_clickable.connect(set_highlight_clickable)
	_hilight.signal_attach_board.connect(attach_board_to_highlights)
	_initiate()
	for element in unit_dict:
		if unit_dict[element].stats.owner != "Player":
			unit_dict[element].destination.connect(draw_non_player_unit_path)

func _initiate() -> void:
	unit_dict = level_instance.return_preplaced_units()
	for unit in unit_dict.values():
		unit.gameboard = self
	
func tile_clicked(cell: Vector2i) -> void:
	if !fsm.state is PlayerTurnState:
		return
	if is_occupied(cell):
		_select_unit(cell)
	elif active_unit:
		if active_unit.is_selected:
			_move_active_unit(cell)

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
		if fsm.state is PlayerTurnState:
			_unit_path.draw(active_unit.cell, cell)
		

func attach_board_to_highlights() -> void:
	_hilight.tile_board = level_instance

func _select_unit(cell: Vector2i) -> void:
	if !unit_dict.has(cell):
		return
	active_unit = unit_dict[cell]
	saved_active_unit = active_unit
	if _check_status_requirements():
		return
	if _check_for_wrong_state():
		return
	if !active_unit.is_selected:
		active_unit.is_selected = true
		#need to check if unit belongs to player
		var move_range = active_unit.move_range
		if active_unit.has_moved:
			move_range = 0
		var flood_fill_array: Array = flood_fill(active_unit.cell, move_range)
		walkable_cells = flood_fill_array
		#flood_fill = level_instance.return_move_array_sans_obstructions(flood_fill)
		_hilight.flood_fill_highlight(flood_fill_array, active_unit.cell)
		if active_unit.stats.owner != "Player":
			active_unit.activate(flood_fill_array)
		if active_unit.stats.owner == "Player":
			_ability_button.button_active(active_unit.stats, true)
			

func auto_select_unit(cell: Vector2i) -> Array:
	_select_unit(cell)
	var flood_fill_array: Array = flood_fill(active_unit.cell, active_unit.move_range)
	return flood_fill_array
	
func _deselect_active_unit() -> void:
	if !active_unit:
		return
	active_unit.is_selected = false
	_hilight.clear_flood_fill()
	_unit_path.stop()

func _clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()

func _move_active_unit(new_cell: Vector2i) -> void:
	active_unit.move_distance = abs(new_cell.x - active_unit.cell.x) +\
	abs(new_cell.y - active_unit.cell.y)
	_gametracker.reduce_status(active_unit, fsm.state)
	if is_occupied(new_cell) or not new_cell in walkable_cells:
		return
	unit_dict.erase(active_unit.cell)
	unit_dict[new_cell] = active_unit
	_deselect_active_unit()
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
	for cell in flood_array:
		var path_count = pathfinder.calculate_point_path(origin, cell)
		if path_count.size() > max_dist + 1:
			erase_array.append(cell)
	for cell in erase_array:
		flood_array.erase(cell)
	return flood_array

func change_status_number(new_num: int) -> void:
	_status_label.text = str(new_num)

func _check_status_requirements() -> bool:
	if fsm.state is PlayerTurnState:
		if _gametracker.player_status == 0\
		or _gametracker.player_status - active_unit.stats.status_reduction\
		< 0:
			return true
	if fsm.state is EnemyTurnState:
		if _gametracker.enemy_status == 0\
		or _gametracker.enemy_status - active_unit.stats.status_reduction\
		< 0:
			return true
	return false

func _check_for_wrong_state() -> bool:
	if active_unit.stats.owner == "Player" and fsm.state is PlayerTurnState:
		return false
	if active_unit.stats.owner == "NPC" and fsm.state is NPCTurnState:
		return false
	if active_unit.stats.owner == "Opponent" and fsm.state is EnemyTurnState:
		return false
	return true
	
func _on_texture_button_pressed():
	if fsm.state is PlayerTurnState:
		_ability_button.button_active(active_unit.stats, false)
		if active_unit:
			cancel_active_unit()
		fsm.change_state(npc_turn_state)
		_gametracker.player_status = 10
		_gametracker.enemy_status = 10
		for unit_cell in unit_dict:
			unit_dict[unit_cell].has_moved = false
		change_status_number(_gametracker.player_status)
	
func draw_non_player_unit_path(dest_cell) -> void:
	_unit_path.draw(active_unit.cell, dest_cell)
	await get_tree().create_timer(1).timeout
	_move_active_unit(dest_cell)
	npc_turn_state.run_npc_moves()

func cancel_active_unit() -> void:
	_deselect_active_unit()
	_clear_active_unit()

func _on_texture_button_2_pressed() -> void:
	if fsm.state is PlayerTurnState:
		fsm.change_state(player_ability_state)
		var active_tile_highlights: Array = \
		saved_active_unit.ability.show_affect(saved_active_unit.cell, saved_active_unit.move_distance)
		_hilight.flood_fill_attack(active_tile_highlights, saved_active_unit.cell)

func cancel_ability_view() -> void:
	fsm.change_state(player_turn_state)
