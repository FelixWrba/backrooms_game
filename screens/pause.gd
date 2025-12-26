extends Control

signal continue_game

func _on_continue_pressed() -> void:
	continue_game.emit()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://screens/menu.tscn")
