extends TileMap
class_name Level

@export var click_delay: float

var player: CharacterBody2D
var accepting_clicks: bool = true
var test_index_checker: Array = []
var board_size: Vector2i

@onready var _mouse_timer: Timer = $Timer
@onready var _preplaced_units: Node2D = $PreplacedUnits

signal tile_selected
signal initiate
# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if accepting_clicks:
			_select_tile()

func _select_tile() -> void:
	accepting_clicks = false
	var tile_pos: Vector2i = local_to_map(get_local_mouse_position())
	if check_tile_status(tile_pos):
		tile_selected.emit(tile_pos)
	_mouse_timer.start(click_delay)

func check_tile_status(cell: Vector2i) -> bool:
	return get_cell_source_id(0, cell) > -1

func return_preplaced_units() -> Dictionary:
	var child_units: Array = _preplaced_units.get_children()
	var child_unit_dict: Dictionary = {}
	for unit: Unit in child_units:
		var cell: Vector2i = local_to_map(unit.position)
		unit.cell = cell
		child_unit_dict[cell] = unit
	return child_unit_dict

func _on_timer_timeout():
	accepting_clicks = true

func return_move_array_sans_obstructions(move_cells: Array) -> Array:
	#var original_cells: Array = move_cells
	var result: Array = []
	for cell in move_cells:
		if get_cell_source_id(0, cell) != -1:
			result.append(cell)

	return result

func return_is_cell_within_bounds(cell: Vector2i) -> bool:
	return get_cell_source_id(0, cell) > -1

func return_as_index(cell: Vector2i) -> int:
	if board_size == Vector2i.ZERO:
		board_size = _get_map_size()
	var test = cell.x + board_size.x * cell.y
	return int(cell.x + board_size.x * cell.y)
	if test_index_checker.has(test):
		assert("Repeated Index in astar")
	test_index_checker.append(test)

func return_pixel_pos_from_grid(cell: Vector2i) -> Vector2:
	var unit_on_map: Vector2 = map_to_local(cell)
	return unit_on_map
	
func _get_map_size() -> Vector2i:
	var size_array = get_used_cells(0)
	var low_range: Vector2i = Vector2i.ZERO
	var high_range: Vector2i = Vector2i.ZERO
	for cell in size_array:
		if cell.x < low_range.x:
			low_range.x = cell.x
		if cell.x > high_range.x:
			high_range.x = cell.x
		if cell.y < low_range.y:
			low_range.y = cell.y
		if cell.y > high_range.y:
			high_range.y = cell.y
	print("low_range: " + str(low_range))
	print("high_range: " + str(high_range))
	return high_range - low_range
		
