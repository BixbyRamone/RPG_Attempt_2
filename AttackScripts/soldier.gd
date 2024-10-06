extends Resource
class_name SoldierAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 0
const instantaneous: bool = false
const soldier_move_limit: int = 4

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	var return_array: Array = []
	var x_val = unit.cell.x
	var y_val = unit.cell.y
	moved_tiles = clamp(moved_tiles,0,2)
	for lim in range(4 - moved_tiles, 1, -1):
		for dir in directions:
			if dir.y == 0:
				var append_cells: Array = []
				append_cells.append(unit.cell + lim*dir)
				append_cells.append(unit.cell + (lim*dir + Vector2i.UP))
				append_cells.append(unit.cell + (lim*dir + Vector2i.DOWN))
				return_array.append_array(append_cells)
			if dir.x == 0:
				var append_cells: Array = []
				append_cells.append(unit.cell + lim*dir)
				append_cells.append(unit.cell + (lim*dir + Vector2i.LEFT))
				append_cells.append(unit.cell + (lim*dir + Vector2i.RIGHT))
				return_array.append_array(append_cells)
	return return_array

func return_affected_cell(hovered_cell: Vector2i, hilighted_cells: Array) -> Array[Vector2i]:
	var return_array: Array[Vector2i]
	if hovered_cell in hilighted_cells:
		return_array.append(hovered_cell)
	else:
		return []
	for cell in return_array:
		for direction in directions:
			var check_cell: Vector2i = cell + direction
			if hilighted_cells.has(check_cell):
				if !return_array.has(check_cell):
					return_array.append(check_cell)	
	return return_array
