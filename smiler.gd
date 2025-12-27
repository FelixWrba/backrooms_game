extends Node3D

@export var speed := 6.0
@export var isHostile := true
@export var attackDistance := 0.7

@onready var player: CharacterBody3D

var isChasingPlayer = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')

func _process(delta: float) -> void:
	if not isHostile: return
	if player.isDead: return
	
	look_at(Vector3(player.global_position.x, 1.4, player.global_position.z))
	
	if isChasingPlayer:
		var direction := (player.global_position - global_position)
		if direction.length() > attackDistance:
			direction = direction.normalized()
			global_position += direction * speed * delta
			global_position.y = 1.4
		else:
			isChasingPlayer = false
			player.call('die', Vector3(deg_to_rad(rotation_degrees.x - 180), deg_to_rad(rotation_degrees.y - 180), 0))
			$AnimationPlayer.play("smiler_attack")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		isChasingPlayer = true
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group('player'):
		isChasingPlayer = false
