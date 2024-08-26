extends State
class_name NPCTurnState

signal end_turn

@export var gameboard: GameBoard

var timer_0:Timer = Timer.new()
const timer_0_time: float = 0.5

var npc_units: Array = []

func _ready():
	set_physics_process(false)

func enter() -> void:
	set_physics_process(true)
	for unit in gameboard.unit_dict:
		if gameboard.unit_dict[unit].stats.owner == "NPC":
			npc_units.append(unit)
	add_child(timer_0)
	await get_tree().create_timer(1).timeout
	run_npc_moves()
	
func exit() -> void:
	set_physics_process(false)
	
func _on_timer0_timeout() -> void:
	run_npc_moves()
			
func run_npc_moves() -> void:
	
	if npc_units.size() > 0:
		var npc_move_options: Array = gameboard.auto_select_unit(npc_units[0])
		npc_units.pop_front()
	else:
		end_turn.emit()
