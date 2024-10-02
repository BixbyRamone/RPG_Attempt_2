extends Node
class_name FiniteStateMachine

signal state_change

@export var state: State

func _ready() -> void:
	change_state(state)
	
func change_state(new_state: State) -> void:
	if state is State:
		state.exit()
	state_change.emit(state, new_state)
	#if new_state is PlayerTurnState:
		#if state != PlayerAbilityState:
			#state_change.emit(new_state)
	#if new_state is EnemyTurnState or new_state is NPCTurnState:
		#state_change.emit(new_state)
	new_state.enter()
	state = new_state


