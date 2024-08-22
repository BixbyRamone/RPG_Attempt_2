extends Node
class_name FiniteStateMachine

@export var state: State

func _ready() -> void:
	change_state(state)
	
func change_state(new_state: State) -> void:
	if state is State:
		state.exit()
	new_state.enter()
	state = new_state
