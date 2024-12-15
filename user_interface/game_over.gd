extends CanvasLayer



func _on_restart_button_pressed() -> void:
	SignalBus.emit_signal("restart_game")
