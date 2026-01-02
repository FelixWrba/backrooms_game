extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var level: Node3D = $Level
@onready var escapeScreen: Control = $EscapeScreen

var canShowEscapeScreen = false

func _ready() -> void:
	# Scene transistion
	var tween = create_tween()
	tween.tween_property($BlackOverlay, 'color', Color(0.0, 0.0, 0.0, 0.0), 1.0)
	tween.tween_property($BlackOverlay, 'visible', false, 0.1)

func _process(_delta: float) -> void:
	if level.visible and player.position.y < -800:
		level.visible = false
		
	if not $WindAudio.playing and not canShowEscapeScreen and not player.is_on_floor() and player.position.y < 0:
		$WindAudio.play()
		
	if $WindAudio.playing and player.is_on_floor():
		$WindAudio.stop()
	
	if not canShowEscapeScreen and player.is_on_floor() and player.position.y < -800:
		canShowEscapeScreen = true
		$Instruction.visible = true
	
	if canShowEscapeScreen and Input.is_action_just_pressed("interact"):
		$Instruction.visible = false
		$Camera3D.position = player.position + Vector3(0, 0.4, 0)
		$Camera3D.rotation.y = player.rotation.y
		remove_child(player)
		$Camera3D.make_current()
		escapeScreen.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_parallel()
		tween.tween_property($Camera3D, 'position', Vector3(230.0, -1010.0, 160.0), 3.0)
		tween.tween_property($Camera3D, 'rotation', Vector3(0.0, 0.0, 0.0), 3.0)
		tween.chain().tween_property(escapeScreen, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 1.0)

func _set_info(title: String, encounters: int) -> void:
	$EscapeScreen/Info/Title.text = title
	$EscapeScreen/Info/Stats.text = 'Begegnungen mit feindlichen Gestalten: ' + str(encounters)

func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file('res://main.tscn')

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file('res://screens/menu.tscn')
