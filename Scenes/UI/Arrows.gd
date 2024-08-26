extends TileMap
class_name UnitPath

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var level_tiles: Level
var _pathfinder: PathFinder
var current_path: PackedVector2Array
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize(walkable_cells: Array) -> void:
	level_tiles = get_tree().get_first_node_in_group("Level")
	_pathfinder = PathFinder.new(level_tiles, walkable_cells)
	
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)
	#for cell in current_path:
		#set_cell(1, cell, 0)
	set_cells_terrain_path(0, current_path, 0, 0)
	set_cell(0, cell_start, 1, Vector2i(2,1))

	update_internals()

func stop() -> void:
	_pathfinder = null
	clear()



