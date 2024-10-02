extends TileMap
class_name MarkedTiles

signal marked_cells

var owner_node_name: String
var marked_tiles_dict: Dictionary = {}

func mark_tiles(cell_array: Array, status_effect: String, unit_name: String, color_int: int) -> void:
	owner_node_name = unit_name
	for cell: Vector2i in cell_array:
		marked_tiles_dict[cell] = status_effect
		set_cell(0, cell, 1, Vector2i(2, color_int))

func accentuate(cell: Vector2i, color_int: int) -> Array[Vector2i]:
	#get cells that are adjacent to cell and are set
	var marked_tiles: Array[Vector2i] = get_used_cells(0)
	var accented_marked_tiles: Array[Vector2i] = []
	accented_marked_tiles.append(cell)
	for cel in accented_marked_tiles:
		var adj_cells: Array[Vector2i] = get_surrounding_cells(cel)
		for adj_cel in adj_cells:
			if adj_cel in marked_tiles:
				accented_marked_tiles.append(adj_cel)
	for cel in accented_marked_tiles:
		set_cell(0, cel, 1, Vector2i(1, color_int))
	return accented_marked_tiles
