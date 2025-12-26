extends CharacterBody3D

@onready var head = $head

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5

var isPaused = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event) -> void:
	if event is InputEventMouseMotion and not isPaused:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	# Pause game
	if Input.is_action_just_pressed("pause") and not isPaused:
		get_tree().paused = true
		isPaused = true
		get_node('head/Camera3D/pause').visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Die
	if Input.is_action_just_pressed('ui_up'):
		get_tree().paused = true
		get_node('head/Camera3D/death').visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Unpause game
func _on_pause_continue_game() -> void:
		get_tree().paused = false
		isPaused = false
		get_node('head/Camera3D/pause').visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
