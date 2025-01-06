class_name GameController extends Node

var current_2d_scene
var current_gui_scene
var transition_controller : Control
var gui : Control
var world = preload("res://world/test_world_1.tscn") as PackedScene
var hud = preload("res://user_interface/hud.tscn") as PackedScene
var game_over_screen = preload("res://user_interface/game_over.tscn") as PackedScene
var restart_screen
var world_container
var hud_display

#
func _ready() -> void:
	#Engine.time_scale = 0.3
	#print("Game controller ready")
	Global.game_controller = self
	#current_gui_scene = $GUI/SplashScreenManager
	#current_2d_scene = %World_Container
	#transition_controller = $TransitionController
	#splash_screen_manager = %SplashScreenManager
	#world_container = %World_Container
	SignalBus.connect("start_game", _on_main_menu_start_game)
	SignalBus.connect("game_over", _on_game_over)
	
	# Instantiate and hide HUD
	hud_display = hud.instantiate()
	add_child(hud_display)
	hud_display.hide()
	
	
	# Instantiate and hide game over screen
	restart_screen = game_over_screen.instantiate()
	add_child(restart_screen)
	restart_screen.hide()
	
	

#func _process(_delta: float) -> void:
	#change_gui_scene(current_gui_scene)
#
# New scene = path
func change_gui_scene(
	new_scene: String, 
	delete: bool = true, 
	keep_running: bool = false,
	transition : bool = true,
	transition_in : String = "FadeIn",
	transition_out : String = "FadeOut",
	seconds : float = 1.0
) -> void:
	
	if transition:
		transition_controller.transition(transition_out, seconds) # Transition Out
		await transition_controller.animation_player.animation_finished
	
	if current_gui_scene != null:
		if delete: 
			current_gui_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_gui_scene.visible = false # Keeps in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	
	current_gui_scene = new
	transition_controller.transition(transition_in, seconds) # Transition In
	
func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_2d_scene != null:
		if delete: current_2d_scene.queue_free() # Removes node entirely
	elif keep_running:
		current_2d_scene.visible = false # Keeps in memory and running
	else:
		gui.remove_child(current_2d_scene) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	add_child(new)
	current_2d_scene = new
 


func _on_main_menu_start_game() -> void:
	#print("Start game signal receieved")
	#var current_world = world.instantiate()
	#world_container.add_child(current_world)
	get_tree().change_scene_to_packed(world)
	#change_2d_scene(world)
	#change_gui_scene(hud, false, true)

func _on_game_over() -> void:
	restart_screen.show()
