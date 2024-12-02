extends CharacterBody2D

@export var jump_buffer_time: float = .1

const GRAVITY : int = 4200
const JUMP_VELOCITY : = -800
const FALL_GRAVITY := GRAVITY * 3

var jump_buffer: bool = false
var jump_available: bool = true



func _physics_process(delta: float) -> void:
	velocity.y += get_cat_gravity(velocity) * delta
	#Dynamic jump height  
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
				velocity.y = JUMP_VELOCITY / 100 #Adjust the number to fine tune jump behaviour
				#jump_available = false
	else:
	
		if is_on_floor():
			jump_available = true
			if jump_buffer:
				if not get_parent().game_running:
					#jump_available = false
					$AnimatedSprite2D.play("idle")
				else:
					# Handle jump.
					if Input.is_action_just_pressed("ui_accept"):
						if jump_available:
							jump()
							jump_buffer = false
						else:
							jump_buffer = true
							get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timer_timeout)
				
						#$JumpSound.play()
						
					#Add dash animation later
					#elif Input.is_action_pressed("ui_down"):
						#$AnimatedSprite2D.play()
					else:
							$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("jump") 	
			$AnimatedSprite2D.play("in air")
		move_and_slide()

func get_cat_gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY

func jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_available = false
	
func on_jump_buffer_timer_timeout() -> void:
	jump_available = false
	
