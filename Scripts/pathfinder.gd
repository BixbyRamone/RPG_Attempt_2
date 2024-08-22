extends RefCounted
class_name PathFinder

const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

var _grid: Level
var astar: AStar2D = AStar2D.new()

func _init(grid: Level, walkable_cells: Array) -> void:
	_grid = grid
	var cell_mappings:= {}
	for cell in walkable_cells:
		cell_mappings[cell] = _grid.return_as_index(cell)
	_add_and_connect_points(cell_mappings)
	
func calculate_point_path(start: Vector2i, end: Vector2i) -> PackedVector2Array:
	var start_index: int = _grid.return_as_index(start)
	var end_index: int = _grid.return_as_index(end)
	if astar.has_point(start_index) and astar.has_point(end_index):
		# The AStar2D object then finds the best path between the two indices.
		return astar.get_point_path(start_index, end_index)
	else:
		return PackedVector2Array()

func _add_and_connect_points(cell_mappings: Dictionary) -> void:
	for point in cell_mappings:
		astar.add_point(cell_mappings[point], point)
	for point in cell_mappings:
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			astar.connect_points(cell_mappings[point], neighbor_index)
		
func _find_neighbor_indices(cell: Vector2i, cell_mappings: Dictionary) -> Array:
	var out := []	
	for direction in DIRECTIONS:
		var neighbor: Vector2i = cell + direction
		if not cell_mappings.has(neighbor):
			continue
		if not astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			out.push_back(cell_mappings[neighbor])
	return out
