extends State
class_name LaborerNPC

signal signal_dest_to_unit

const directions: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
@export var unit: Unit
@export var identity: int = 0 #this matches laborer to tile

var tiles_to_choose: Array = []
var tilemap: TileMap
var gameboard: GameBoard

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var timer_0:Timer = Timer.new()
const timer_0_time: float = 1.0

func  _ready() -> void:
	set_physics_process(false)
	
func enter() -> void:
	set_physics_process(true)
	await get_tree().create_timer(1).timeout
	tiles_to_choose = find_dest()
	var destination: Vector2i = tiles_to_choose[rng.randi_range(0, tiles_to_choose.size()-1)]
	while destination == unit.cell:
		destination = tiles_to_choose[rng.randi_range(0, tiles_to_choose.size()-1)]
	signal_dest_to_unit.emit(destination)

	
func _on_timer0_timeout() -> void:
	var destination: Vector2i = tiles_to_choose[rng.randi_range(0, tiles_to_choose.size()-1)]
	signal_dest_to_unit.emit(destination)

func find_dest() -> Array:
	var preferred_tiles_array: Array = []
	#var array_of_dest: Array = []
	for item in tiles_to_choose:
		var target_cell_data: = tilemap.get_cell_atlas_coords(0, item)
		var j: int = check_adjacents(item)
		var i: int = 0
		while i < j:
			preferred_tiles_array.append(item)
			i += 1
		
	return tiles_to_choose + preferred_tiles_array

func check_adjacents(cell: Vector2i) -> int:
	var weighter: int = 0
	for direction in directions:
		var target_cell_data: Vector2i = tilemap.get_cell_atlas_coords(0, cell + direction)
		if target_cell_data.x == identity:
			weighter += 1
			if identity == 1:
				if gameboard.unit_dict.has(cell + direction):
					var unit: Unit = gameboard.unit_dict[cell + direction]
					if unit.stats is TreeStats:
						weighter += 2
	return weighter
