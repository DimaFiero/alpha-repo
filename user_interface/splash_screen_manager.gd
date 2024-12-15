extends Control

#@export var load_scene : PackedScene
@export var in_time : float = 0.1
@export var fade_in_time : float = .5
@export var pause_time : float = 1.0
@export var fade_out_time : float = .5
@export var out_time : float = 0.5
@export var splash_screen_container : Node

var splash_screens : Array

func get_screens() -> void:
	splash_screens = splash_screen_container.get_children()
	for screen in splash_screens:
		screen.modulate.a = 0.0
		
func _ready() -> void:
	$ColorRect.color = Refs.black
	get_screens()
	fade()

func fade() -> void:
	for screen in splash_screens:
		var tween = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
		tween.tween_interval(out_time)
		await tween.finished
	get_tree().change_scene_to_packed(Global.main_menu)
	#Global.game_controller.change_gui_scene(Global.main_menu)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		#Global.game_controller.change_gui_scene(Global.main_menu)
		get_tree().change_scene_to_packed(Global.main_menu)
