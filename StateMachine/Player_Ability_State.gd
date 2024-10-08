extends State
class_name PlayerAbilityState

signal exit_ability_state
signal run_ability

func _ready():
	set_physics_process(false)
	set_process(false)
	
func enter():
	set_physics_process(true)
	set_process(true)

func exit():
	set_physics_process(false)
	set_process(false)

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		exit_ability_state.emit()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		run_ability.emit()
