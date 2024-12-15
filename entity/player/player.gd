extends CharacterBody2D

#region Player Variables

# Nodes
@onready var sprite = $AnimatedSprite2D
@onready var collider = $CollisionShape2D
@onready var sound = $JumpSound
@onready var states = $StateMachine
@onready var jump_buffer_timer = $Timers/JumpBuffer

# Physics variables
#const RUNSPEED = 150
const GRAVITY_JUMP = 600
const GRAVITY_FALL = 1000
const MAX_FALL_VELOCITY = 300
const JUMP_VELOCITY = -240
const VARIABLE_JUMP_MULTIPLIER = 0.5
const MAX_JUMPS = 1
const JUMP_BUFFER_TIME = 0.15 # 9 frames

var jump_speed = JUMP_VELOCITY
var jumps = 0

# Input variables
var key_jump = false
var key_jump_pressed = false

# State Machine
var current_state = null
var previous_state = null
#endregion

#region Util Variables
var time: float 
#endregion

#region Main Loop Functions

func _ready() -> void:
	# Initialize state machine
	for state in states.get_children():
		state.states = states
		state.player = self
	previous_state = states.Fall
	current_state = states.Fall

func _draw():
	current_state.Draw()

func _physics_process(delta: float) -> void:
	
	time += delta
	#Global.debug.add_debug_property("Every 60 Frames", time, 60)
	#Global.debug.add_debug_property("Every 30 Frames", time, 30)
	#Global.debug.add_debug_property("Every 10 Frames", time, 10)
	#Global.debug.add_debug_property("Every Frame", time, 1)
	
	# Get input states
	GetInputStates()

	# Update current state
	current_state.Update(delta)
	#print(current_state.name)
	
	# Handle movement
	HandleMaxFallVelocity()
	HandleJump()
	
	# Commit movement
	move_and_slide()
	

func ChangeState(new_state):
	if new_state != null:
		previous_state = current_state
		current_state = new_state
		previous_state.ExitState()
		current_state.EnterState()
		return
	

#endregion

#region Custom Funtions

func GetInputStates():
	key_jump = Input.is_action_pressed("KeyJump")
	key_jump_pressed = Input.is_action_just_pressed("KeyJump")

func HandleGravity(delta, gravity: float = GRAVITY_JUMP):
	if !is_on_floor():
		velocity.y += gravity * delta

func HandleLanding():

		if is_on_floor():
			jumps = 0
			if get_tree().current_scene.game_running:
				ChangeState(states.Run)
			else:
				ChangeState(states.Idle)

func HandleJumpBuffer():
	if key_jump_pressed:
		jump_buffer_timer.start(JUMP_BUFFER_TIME)

func HandleFalling():
	# See if we jumped  off a ledge, if so go to fall state
	if !is_on_floor():
		ChangeState(states.Fall)

func HandleMaxFallVelocity():
	if velocity.y > MAX_FALL_VELOCITY: velocity.y = MAX_FALL_VELOCITY

func HandleJump():
	if (key_jump_pressed or jump_buffer_timer.time_left > 0)  and (jumps < MAX_JUMPS):
			jumps += 1
			jump_buffer_timer.stop()
			ChangeState(states.Jump)
	

#endregion
