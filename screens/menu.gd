extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("menu_start")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	$AnimationPlayer.play("menu_animation")

func _on_info_button_pressed() -> void:
	$Camera3D/menu/AcceptDialog.show()
