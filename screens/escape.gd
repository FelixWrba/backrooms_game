extends Node3D

func _set_info(title: String, encounters: int) -> void:
	$EscapeScreen/Info/Title.text = title
	$EscapeScreen/Info/Stats.text = 'Begegnungen mit feindlichen Gestalten: ' + str(encounters)

func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file('res://screens/menu.tscn')
