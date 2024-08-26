extends Node2D
class_name GameTracker

signal signal_shut_off_turns
signal new_status_number
@export var player_status: int = 10
@export var enemy_status: int = 10

#@export var status: Dictionary = {
	#PlayerTurnState: 10,
	#EnemyTurnState: 10
#}

func reduce_status(unit: Unit, state: State) -> void:
	var reduction: int = unit.stats.status_reduction
	if state is PlayerTurnState:
		if player_status - reduction < 0:
			shut_off_turns()
			return
		player_status -= reduction
		new_status_number.emit(player_status)
	if state is EnemyTurnState:
		if enemy_status - reduction < 0:
			shut_off_turns()
			return
		enemy_status -= reduction
		new_status_number.emit(enemy_status)
	
func end_turn():
	pass
	
func shut_off_turns() -> void:
	signal_shut_off_turns.emit()

