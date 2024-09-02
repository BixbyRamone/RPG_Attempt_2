extends Resource
class_name PriestAbility

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

func show_affect(cell: Vector2i, moved_tiles: int) -> Array:
	var return_array: Array = []
	var x_val = cell.x
	var y_val = cell.y
	
	for dx in range(-moved_tiles + 1, moved_tiles):
		for dy in range(-moved_tiles + 1, moved_tiles):
			return_array.append(Vector2i(x_val + dx, y_val + dy))
	
	return return_array
	
