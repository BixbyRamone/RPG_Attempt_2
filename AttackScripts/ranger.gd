extends Resource
class_name RangerAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 0
const instantaneous: bool = true

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	var return_array: Array = []
	var x_val = unit.cell.x
	var y_val = unit.cell.y
	for dir in directions:
		var obstuction: bool = false
		var i: int = 1
		while i < 6:
			if obstuction:
				i += 1
				continue
			var append_cell: Vector2i = unit.cell + dir * i
			if i != 1:
				return_array.append(append_cell)
			i += 1
			
			if unit_dict.has(append_cell):
				obstuction = true
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
