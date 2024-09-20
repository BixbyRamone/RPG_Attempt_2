extends TileMap
class_name MarkedTiles

signal marked_cells

var owner_node_name: String
var marked_tiles_dict: Dictionary = {}

func mark_tiles(cell_array: Array, status_effect: String, unit_name: String) -> void:
	owner_node_name = unit_name
	for cell: Vector2i in cell_array:
		marked_tiles_dict[cell] = status_effect
		set_cell(0, cell, 0, Vector2i(2,0))
