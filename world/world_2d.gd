extends Node2D

@export_group("Nodes")
@export var bg : ParallaxBackground
@export var platform : StaticBody2D
@export var cat : CharacterBody2D
@export var camera : Camera2D

#region Preload obstacles
var barrel_scene = preload("res://world/barrel.tscn")
var box_scene = preload("res://world/box.tscn")
var skull_scene = preload("res://world/skull.tscn")
var obstacle_types := [barrel_scene, box_scene]
var obstacles : Array
var skull_heights := [50, 90]
var gui_hud = preload("res://user_interface/hud.tscn")
var gui_game_over = preload("res://user_interface/game_over.tscn")

#endregion

#region Game variables
const CAT_START_POS := Vector2i(50, 100)
const CAM_START_POS := Vector2i(240, 80)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 35
var high_score : int
var speed : float
const START_SPEED : float = 5.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var platform_height : int
var game_running : bool
var last_obs

#endregion

#region Main Loop Functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	platform_height = platform.get_node("Sprite2D").texture.get_height()
	SignalBus.connect("restart_game", _on_restart_game)
	Game.hud_display.show()
	new_game()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(cat.current_state)
	if game_running:
		
		# Speed up and adjust difficulty
		
		@warning_ignore("integer_division")
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficluty()
		
		# Generate obstacles
		generate_obs()
		
		# Move cat and camera
		cat.position.x += speed
		camera.position.x += speed
		
		# Update score
		@warning_ignore("narrowing_conversion")
		score += speed
		show_score()
		
		# Update platform position
		if camera.position.x - platform.position.x > screen_size.x * 1.5:
			platform.position.x += screen_size.x
			
		# Remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < camera.position.x - screen_size.x:
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			Game.hud_display.get_node("StartLabel").hide()

#endregion

#region Custom Functions

func new_game() -> void:
	# Reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	# Delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	# Reset nodes
	cat.position = CAT_START_POS
	cat.velocity = Vector2i(0, 0)
	cat.ChangeState(cat.states.Idle)
	camera.position = CAM_START_POS
	platform.position = Vector2i(0, 0)
	
	# Reset HUD and game over screen
	Game.hud_display.press_space_to_start_label.show()
	Game.restart_screen.hide()

func generate_obs() -> void:
	# Generate platform obstaceles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(30, 50):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			#var obs_height = obs.get_node("Sprite2D").texture.get_height()
			#var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - platform_height #- obs_height #* obs_scale.y / 2) #+ 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		# Additionally random chance to spawn skull
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				# Generate skull obstacle
				obs = skull_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = skull_heights[randi() % skull_heights.size()]
				add_obs(obs, obs_x, obs_y)
	
func add_obs (obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)	
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Cat":
		game_over()
#
func show_score() -> void:
	@warning_ignore("integer_division")
	Game.hud_display.distance_label.text = "ДИСТАНЦИЯ: " + str(score / SCORE_MODIFIER)
 
func check_high_score():
	if score > high_score:
		high_score = score
	@warning_ignore("integer_division")
	Game.hud_display.max_distance_label.text = "РЕКОРД: " + str(high_score / SCORE_MODIFIER)

func adjust_difficluty() -> void:
	@warning_ignore("integer_division")
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over() -> void:
	check_high_score()
	get_tree().paused = true
	game_running = false
	SignalBus.game_over.emit	()
 
func _on_restart_game() -> void:
	new_game()

#endregion
