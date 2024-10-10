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
var active_tile_highlights: Array = []
var npc_is_done: bool = false

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var player_turn_state: PlayerTurnState = $FiniteStateMachine/PlayerTurnState
@onready var npc_turn_state: NPCTurnState = $FiniteStateMachine/NPCTurnState
@onready var player_ability_state: PlayerAbilityState = $FiniteStateMachine/PlayerAbilityState
@onready var status_check_state: CheckState = $FiniteStateMachine/CheckState

@onready var _gametracker: GameTracker = $GameTracker
@onready var _status_label: Label = $Camera2D/Label
@onready var _hilight: TileHighlight = $Hilgight_TileMap
@onready var _npc_delay_timer: Timer = $Timer
@onready var _unit_path: UnitPath = $Hilgight_TileMap/Arrows
@onready var _ability_button: AbilityButton = $Camera2D/AbilityButton

func _ready():
	fsm.state_change.connect(check_state_for_status_change)
	_status_label.text = str(_gametracker.player_status)
	player_turn_state.clicked.connect(player_state_clicked)
	#npc_turn_state.end_turn.connect(fsm.change_state.bind(player_turn_state))
	npc_turn_state.end_turn.connect(pc_turn_ended)
	player_turn_state.deselect_unit.connect(cancel_active_unit)
	player_ability_state.exit_ability_state.connect(cancel_ability_view)
	player_ability_state.run_ability.connect(run_active_unit_ability)
	status_check_state.complete_check_state.connect(start_next_round)
	#_gametracker.new_status_number.connect(change_status_number)
	level_instance = level.instantiate()
	add_child(level_instance)
	level_instance.tile_selected.connect(tile_clicked)
	_hilight.check_cell_clickable.connect(set_highlight_clickable)
	_hilight.signal_attach_board.connect(attach_board_to_highlights)
	_initiate()
	for element in unit_dict:
		if unit_dict[element].stats.owner != "Player":
			unit_dict[element].destination.connect(draw_non_player_unit_path)

func _process(_delta):
	_status_label.text = str(fsm.state.name)
	
func player_state_clicked() -> void:
	level_instance.select_tile()
	
func _initiate() -> void:
	unit_dict = level_instance.return_preplaced_units()
	for unit in unit_dict.values():
		unit.gameboard = self
			
func tile_selected(cell: Vector2i) -> void:
	#player_turn_state only
	if is_occupied(cell):
		_select_unit(cell)
	elif active_unit.is_selected:
		_move_active_unit(cell)
	
func tile_clicked(cell: Vector2i, _new_state: State = null) -> void:
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
	if fsm.state is PlayerAbilityState:
		if active_tile_highlights.has(cell):
			var affected_tiles: Array
			if saved_active_unit.ability.has_method("return_affected_cell"):
				affected_tiles = saved_active_unit.ability.return_affected_cell(cell, active_tile_highlights)
			else:
				affected_tiles = active_tile_highlights
			_hilight.accent_attack_tiles(affected_tiles)
			_display_attack_effect(saved_active_unit.ability, affected_tiles)
			#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				#run_active_unit_ability()
		else:
			_hilight.flood_fill_attack(active_tile_highlights, saved_active_unit.cell)
			_hide_attack_effect(active_tile_highlights)
#
func attach_board_to_highlights() -> void:
	_hilight.tile_board = level_instance
#
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
#
func _move_active_unit(new_cell: Vector2i) -> void:
	_gametracker.reduce_status(active_unit, fsm.state)
	if is_occupied(new_cell) or not new_cell in walkable_cells:
		return
	active_unit.move_distance = abs(new_cell.x - active_unit.cell.x) +\
	abs(new_cell.y - active_unit.cell.y)
	unit_dict.erase(active_unit.cell)
	unit_dict[new_cell] = active_unit
	_deselect_active_unit()
	active_unit.walk_along(_unit_path.current_path)
	await active_unit.walk_finished
	await get_tree().create_timer(0.7)
	if npc_is_done:
		fsm.change_state(status_check_state)
		npc_is_done = false
	_clear_active_unit()
	#
func _on_timer_timeout():
	_initiate()
#
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
	#
func array_check(flood_array: Array, max_dist: int, origin: Vector2i) -> Array:
	##cleans up array in cases of absent ground tiles
	var pathfinder = PathFinder.new(level_instance, flood_array)
	var erase_array: Array = []
	for cell in flood_array:
		var path_count = pathfinder.calculate_point_path(origin, cell)
		if path_count.size() > max_dist + 1:
			erase_array.append(cell)
	for cell in erase_array:
		flood_array.erase(cell)
	return flood_array
#
func change_status_number(new_num: int) -> void:
	_status_label.text = str(new_num)
#
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
#
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
		if saved_active_unit:
			_ability_button.button_active(saved_active_unit.stats, false)
		if active_unit:
			cancel_active_unit()
		fsm.change_state(npc_turn_state)
		_gametracker.player_status = 10
		_gametracker.enemy_status = 10
		for unit_cell in unit_dict:
			unit_dict[unit_cell].has_moved = false
			unit_dict[unit_cell].move_distance = 0
		#change_status_number(_gametracker.player_status)
	
func draw_non_player_unit_path(dest_cell) -> void:
	_unit_path.draw(active_unit.cell, dest_cell)
	await get_tree().create_timer(1).timeout
	_move_active_unit(dest_cell)
	npc_turn_state.run_npc_moves()
#
func cancel_active_unit() -> void:
	_deselect_active_unit()
	_clear_active_unit()
#
func _on_texture_button_2_pressed() -> void:
	if fsm.state is PlayerTurnState:
		fsm.change_state(player_ability_state)
		active_tile_highlights = \
		saved_active_unit.ability.show_affect(saved_active_unit, saved_active_unit.move_distance, unit_dict)
		var test = saved_active_unit.cell
		if active_tile_highlights.has(test):
			pass
		active_tile_highlights.erase(test)
		if test in active_tile_highlights:
			pass
		active_tile_highlights.erase(saved_active_unit.cell)
		_hilight.flood_fill_attack(active_tile_highlights, saved_active_unit.cell)
		#_display_attack_effect(saved_active_unit.ability, active_tile_highlights)

func cancel_ability_view() -> void:
	fsm.change_state(player_turn_state)

func run_active_unit_ability() -> void:
	_hilight.clear_flood_fill()
	var affected_tiles: Array
	if saved_active_unit.ability.has_method("return_affected_cell"):
		var cell: Vector2i = _hilight.local_to_map(get_local_mouse_position())
		affected_tiles = saved_active_unit.ability.return_affected_cell(cell, active_tile_highlights)
	else:
		affected_tiles = active_tile_highlights
	for cell: Vector2i in affected_tiles:
		if unit_dict.has(cell):
			if unit_dict[cell] != saved_active_unit:
				unit_dict[cell].set_status(saved_active_unit.ability.status_int, fsm.state)
	if !saved_active_unit.ability.instantaneous:
		pass
	saved_active_unit.mark_tiles(affected_tiles, saved_active_unit.stats.status)
	saved_active_unit.has_moved = true
	active_tile_highlights = []
	saved_active_unit = null
	fsm.change_state(player_turn_state)

func _display_attack_effect(ability: Resource, tiles: Array) -> void:
	for tile in tiles:
		if unit_dict.has(tile):
			if unit_dict[tile] != saved_active_unit:
				var this_unit: Unit = unit_dict[tile]
				var status_int: int = ability.status_int
				this_unit.show_attack_status(status_int)

func _hide_attack_effect(tiles: Array) -> void:
	for tile in tiles:
		if unit_dict.has(tile):
			unit_dict[tile].show_attack_status(1)
			
func _get_units_by_owner(owner: String) -> Array:
	var unit_array: Array = []
	for unit in unit_dict.values():
		if owner == unit.owner:
			unit_array.append(unit)
	return unit_array

func check_state_for_status_change(previous_state: State, incoming_state: State) -> void:
	_status_label.text = incoming_state.name
	for unit: Unit in unit_dict.values():
		if unit.stats.owner == "Resource":
			continue
		if incoming_state is PlayerTurnState and previous_state is PlayerAbilityState:
			_deselect_active_unit()
			_clear_active_unit()
		if incoming_state is PlayerTurnState and not previous_state is PlayerAbilityState:
			_deselect_active_unit()
			_clear_active_unit()
			if unit.stats.owner == "Player":
				unit.stats.status = unit.stats.status_array[1]
				unit._set_status_icon()
				unit.clear_marked_tiles()

func pc_turn_ended() -> void:
	npc_is_done = true

func start_next_round() -> void:
	fsm.change_state(player_turn_state)
