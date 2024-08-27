extends State
class_name PlayerTurnState

signal deselect_unit

func _ready():
	set_physics_process(false)
	
func enter():
	set_physics_process(true)

func exit():
	set_physics_process(false)

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		deselect_unit.emit()
