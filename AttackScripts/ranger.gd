extends Resource
class_name RangerAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 0
const priest_move_cap: int = 3

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	var return_array: Array = []
	var x_val = unit.cell.x
	var y_val = unit.cell.y
	for dir in directions:
		var obstuction: bool = false
		var i: int = 2
		while i < 6:
			if obstuction:
				i += 1
				continue
			var append_cell: Vector2i = unit.cell + dir * i
			return_array.append(append_cell)
			i += 1
			if unit_dict.has(append_cell):
				obstuction = true
	return return_array
