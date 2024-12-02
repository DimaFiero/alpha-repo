extends Node2D

#Preload obstacles
var barrel_scene = preload("res://scenes/barrel.tscn")
var box_scene = preload("res://scenes/box.tscn")
var skull_scene = preload("res://scenes/skull.tscn")
var obstacle_types := [barrel_scene, box_scene]
var obstacles : Array
var skull_heights := [50, 90]


#Game variables
const CAT_START_POS := Vector2i(50, 50)
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	platform_height = $Platform.get_node("Sprite2D").texture.get_height()
	$"../GUI/GameOver".get_node("Button").pressed.connect(new_game)
	new_game()
	 # Replace with function body.

func new_game() -> void:
	#Reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#Delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#Reset nodes
	$Cat.position = CAT_START_POS
	$Cat.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Platform.position = Vector2i(0, 0)
	
	#Reset HUD and game over screen
	$"../GUI/HUD".get_node("StartLabel").show()
	$"../GUI/GameOver".hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if game_running:
		#Speed up and adjust difficulty
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficluty()
		#Generate obstacles
		#generate_obs()
		
		#Move cat and camera
		$Cat.position.x += speed
		$Camera2D.position.x += speed
		
		#Update score
		score += speed
		show_score()
		
		#Update platform position
		if $Camera2D.position.x - $Platform.position.x > screen_size.x * 1.5:
			$Platform.position.x += screen_size.x
			
		#Remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < $Camera2D.position.x - screen_size.x:
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$"../GUI/HUD".get_node("StartLabel").hide()

func generate_obs() -> void:
	#Generate platform obstaceles
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
		#Additionally random chance to spawn skull
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#Generate skull obstacele
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

func show_score() -> void:
	$"../GUI/HUD".get_node("DistanceLabel").text = "DISTANCE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
	$"../GUI/HUD".get_node("MaxDistanceLabel").text = "MAX DISTANCE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficluty() -> void:
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over() -> void:
	check_high_score()
	get_tree().paused = true
	game_running = false
	$"../GUI/GameOver".show()
