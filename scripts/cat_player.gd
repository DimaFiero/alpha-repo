extends CharacterBody2D

@export_category("Movement Parameters")
@export var jump_peak_time: float = .5
@export var jump_fall_time: float = .5
@export var jump_height: float = 2.0


var jump_velocity: float = 5.0
var jump_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_gravity: float = 5.0

func _ready() -> void:
	Calculate_Movement_Parameters()

func Calculate_Movement_Parameters() -> void:
	jump_gravity = (2 * jump_height) / pow(jump_peak_time, 2)
	fall_gravity = (2 * jump_height) / pow(jump_fall_time, 2)
	jump_velocity = jump_gravity * jump_peak_time
	
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
