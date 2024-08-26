extends State
class_name LaborerNPC

signal signal_dest_to_unit

@export var unit: Unit

var tiles_to_choose: Array = []
var tilemap: TileMap

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var timer_0:Timer = Timer.new()
const timer_0_time: float = 1.0

func  _ready() -> void:
	set_physics_process(false)
	
func enter() -> void:
	set_physics_process(true)
	await get_tree().create_timer(1).timeout
	var destination: Vector2i = tiles_to_choose[rng.randi_range(0, tiles_to_choose.size()-1)]
	signal_dest_to_unit.emit(destination)
	#timer_0.one_shot = true
	#add_child(timer_0)
	#timer_0.connect("timeout", _on_timer0_timeout)
	#timer_0.start(timer_0_time)
	
func _on_timer0_timeout() -> void:
	var destination: Vector2i = tiles_to_choose[rng.randi_range(0, tiles_to_choose.size()-1)]
	signal_dest_to_unit.emit(destination)
