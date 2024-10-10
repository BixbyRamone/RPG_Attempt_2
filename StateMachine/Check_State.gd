extends State
class_name CheckState

@export var gameboard: GameBoard
@export var camera_player: CharacterBody2D
@export var player_turn_state: State

signal complete_check_state

func _ready():
	set_physics_process(false)
	set_process(false)
	
func enter():
	set_physics_process(true)
	set_process(true)
	for unit in gameboard.unit_dict.values():
		_check_status(unit)
	complete_check_state.emit()

func exit():
	set_physics_process(false)
	set_process(false)

func _check_status(unit: Unit) -> void:
	if unit.stats.status == "dead":
		await get_tree().create_timer(0.5).timeout
		gameboard.unit_dict.erase(unit.cell)
		unit.queue_free()
