extends Resource
class_name ClericAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 3
const cleric_move_limit: int = 3

func show_affect(cell: Vector2i, moved_tiles: int) -> Array:
	var return_array: Array = []
	var x_val = cell.x
	var y_val = cell.y
	
	for dx in range(-cleric_move_limit + moved_tiles - 1, cleric_move_limit - moved_tiles + 2):
		for dy in range(-cleric_move_limit + moved_tiles - 1, cleric_move_limit - moved_tiles + 2):
			return_array.append(Vector2i(x_val + dx, y_val + dy))
	
	return return_array
	
