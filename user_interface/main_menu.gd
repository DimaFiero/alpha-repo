extends Control

func _on_start_button_pressed() -> void:
	SignalBus.emit_signal("start_game")
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
