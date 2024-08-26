extends State
class_name NPCTurnState

@export var gameboard: GameBoard

var timer_0:Timer = Timer.new()
const timer_0_time: float = 0.5

var npc_units: Array = []

func _ready():
	set_physics_process(false)

func enter() -> void:
	set_physics_process(true)
	add_child(timer_0)
	timer_0.one_shot = true
	timer_0.connect("timeout", _on_timer0_timeout)
	timer_0.start(timer_0_time)
	
func exit() -> void:
	set_physics_process(false)
	
func _on_timer0_timeout() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var test = gameboard.unit_dict
	for unit in gameboard.unit_dict:
		if gameboard.unit_dict[unit].stats.owner == "NPC":
			npc_units.append(unit)
	var npc_move_options: Array = gameboard.auto_select_unit(npc_units[0])
			
