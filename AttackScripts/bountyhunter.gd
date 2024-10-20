extends Resource
class_name BountyHunterAbility

const directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT,\
Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 4
const instantaneous: bool = true

var carried_unit: Unit

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	var retun_array: Array = []
	
	for dir in directions:
		var check_tile: Vector2i = unit.cell + dir
		retun_array.append(check_tile)
	return retun_array

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
