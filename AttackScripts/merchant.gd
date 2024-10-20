extends Resource
class_name MerchantAbility

const directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT,\
Vector2i.DOWN, Vector2i.LEFT]
const status_int: int = 4
const instantaneous: bool = true

var carried_unit: Unit

func show_affect(unit: Unit, moved_tiles: int, unit_dict: Dictionary) -> Array:
	var retun_array: Array = []
	
	for dir in directions:
		var check_tile: Vector2i = unit.cell + dir
		if unit_dict[check_tile].owner == "Resource":
			retun_array.append(check_tile)
	return retun_array
