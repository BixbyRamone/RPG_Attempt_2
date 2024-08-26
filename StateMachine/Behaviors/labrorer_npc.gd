extends State
class_name LaborerNPC

signal run_behavior

@export var unit: Unit
var timer_0:Timer = Timer.new()
const timer_0_time: float = 0.5

func  _ready() -> void:
	pass
	#add_child(timer_0)
	#timer_0.connect("timeout", _on_timer0_timeout)
	#timer_0.start(timer_0_time)
	
func _on_timer0_timeout() -> void:
	pass
	
