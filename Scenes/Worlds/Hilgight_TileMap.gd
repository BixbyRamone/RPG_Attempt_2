extends TileMap
class_name TileHighlight

@export var tile_board: Level

var cell_is_clickable: bool = true
var cell_is_active: bool = false

signal check_cell_clickable
signal signal_attach_board
# Called when the node enters the scene tree for the first time.
@onready var _label = $Label
@onready var _flood_fill: TileMap = $FloodFill
@onready var _arrow: UnitPath = $Arrows

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_highlight_cell()
	
	
func _highlight_cell() -> void:
	var tile_pos: Vector2i = local_to_map(get_local_mouse_position())
	check_cell_clickable.emit(tile_pos)
	_label.text = str(tile_pos)
	#set_cell(0, tile_pos, 0, Vector2i(0,0))
	var used_cell_array: Array[Vector2i] = get_used_cells(0)
	for cell in used_cell_array:
		if cell != tile_pos:
			set_cell(0, cell, -1)
	if cell_is_clickable:
		set_cell(0, tile_pos, 0, Vector2i(0,0))

func set_highlitable(bul: bool) -> void:
	cell_is_clickable = bul

func flood_fill_highlight(flood_array: Array, unit_cell: Vector2i) -> void:
	_arrow.initialize(flood_array)
	if tile_board != null:
		signal_attach_board.emit()
	cell_is_active = true
	for cell in flood_array:
		_flood_fill.set_cell(0, cell, 0 ,Vector2i(2,0))
		if cell == unit_cell:
			_flood_fill.set_cell(0, cell, 0 ,Vector2i(1,0))

func clear_flood_fill() -> void:
	_flood_fill.clear()

func flood_fill_attack(flood_array: Array, unit_cell: Vector2i) -> void:
	#_arrow.stop()
	_flood_fill.clear()
	if tile_board != null:
		signal_attach_board.emit()
	cell_is_active = true
	for cell in flood_array:
		_flood_fill.set_cell(0, cell, 2 ,Vector2i(0,0))

