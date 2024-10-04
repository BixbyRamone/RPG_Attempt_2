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
