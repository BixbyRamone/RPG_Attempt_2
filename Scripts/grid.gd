# Represents a grid for a tactical game, size width and height and size of each cell in pixels
# helper functions for calculating coordinates
class_name Grid
extends Resource

# grid rows and columns

# first change here is the use of the @ symbol on export
# the decorators in Godot 4 use an @keyword vs 
# just a plain keyword in Godot 3
@export var size := Vector2(30, 30)
@export var cell_size := Vector2(32, 16)

var _half_cell_size = cell_size / 2

# get pixel position from grid coordinates
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size
	
# get grid coordinates from pixel position
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()

# check that cursor or move stays inside grid boundaries

# I just renamed vars / rewrote this to be a little clearer about what it is doing
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var inside_x := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	var inside_y := cell_coordinates.y >= 0 and cell_coordinates.y < size.y
	return inside_x and inside_y

# Godot 4 was not really liking using clamp as the name here 
# since it is a built in func
# so just updated it to be gridclamp	
func gridclamp(grid_position: Vector2) -> Vector2:
	var clamped_position := grid_position
	clamped_position.x = clamp(clamped_position.x, 0, size.x - 1.0)
	clamped_position.y = clamp(clamped_position.y, 0, size.y - 1.0)
	return clamped_position
	
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
