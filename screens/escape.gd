extends Control

func _set_info(title: String, encounters: int) -> void:
	$Info/Title.text = title
	$Info/Stats.text = 'Begegnungen mit feindlichen Gestalten: ' + str(encounters)

func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file('res://screens/menu.tscn')
