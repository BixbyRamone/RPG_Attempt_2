extends Resource
class_name PriestAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 2
const priest_move_cap: int = 3
const instantaneous: bool = false

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	moved_tiles = clamp(moved_tiles, 0, priest_move_cap)
	var return_array: Array = []
	var x_val = unit.cell.x
	var y_val = unit.cell.y
	
	for dx in range(-moved_tiles, moved_tiles+ 1):
		for dy in range(-moved_tiles, moved_tiles + 1):
			var vec: Vector2i = Vector2i(x_val + dx, y_val + dy)
			if unit_dict.has(vec):
				if unit_dict[vec].stats.owner == unit.stats.owner:
					continue
			return_array.append(Vector2i(x_val + dx, y_val + dy))
	
	return return_array
	
