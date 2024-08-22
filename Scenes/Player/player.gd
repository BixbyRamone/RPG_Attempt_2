extends CharacterBody2D
class_name PlayerCameraBody

const SPEED = 100.0
const ACCELERATION = 10.0
const FRICTION = 200.0

var mouse_move_active: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.

func _physics_process(_delta):
	var input_vector: Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var direction: Vector2 = input_vector.normalized()
	if direction:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
	elif !mouse_move_active:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	move_and_slide()

func mouse_move(multiplier: float, vector: Vector2, bul: bool) -> void:
	mouse_move_active = bul
	velocity = velocity.move_toward(vector * SPEED * multiplier, ACCELERATION)
