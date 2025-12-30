extends CharacterBody3D

@export var hasEscaped := false

@onready var head: Node3D = $head
@onready var coordinates: Label = $head/Camera3D/GameOverlay/Coordinates
@onready var crosshair: CenterContainer = $head/Camera3D/GameOverlay/Crosshair
@onready var instruction: Label = $head/Camera3D/GameOverlay/Instruction

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5

var isPaused := false
var isDead := false
var encounters := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crosshair.queue_redraw()

func _physics_process(delta: float) -> void:
	# Display the coordinates:
	coordinates.text = "X: {0} | Y: {1} | Z: {2}".format([str(round(position.x)), str(round(position.y)), str(round(position.z))])
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Ignore inputs when isDead.
	if isDead:
		return
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
	
	if hasEscaped: return
	# Handle exit detection
	var rayIntersetion = $head/RayCast3D.get_collider()
	if rayIntersetion and rayIntersetion.name == 'ExitGreen':
		instruction.visible = true
		if Input.is_action_just_pressed('interact'):
			var escapeScreenInstance = load("res://screens/escape.tscn").instantiate()
			var messages = [
				'Glückwunsch! Sie entkamen den Hinterzimmern unbeschadet.',
				'Erfolg! Sie entkamen den Hinterzimmern mit leichten Verletzungen.',
				'Sie entkamen den Hinterzimmern mit schweren psychischen Schäden.',
			]
			# Switch to exit scene.
			escapeScreenInstance.call('_set_info', messages[clamp(floor(encounters / 2.0), 0, 2)], encounters)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().root.add_child(escapeScreenInstance)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = escapeScreenInstance
	else:
		instruction.visible = false
	
func _input(event) -> void:
	if isDead: return
	
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

# Unpause game
func _on_pause_continue_game() -> void:
	get_tree().paused = false
	isPaused = false
	get_node('head/Camera3D/pause').visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func die(faceAngle: Vector3) -> void:
	rotate_y(faceAngle.y)
	head.rotate_x(faceAngle.z)
	isDead = true
	$AnimationPlayer.play("death")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Draw crosshair
func _on_crosshair_draw() -> void:
	crosshair.draw_circle(Vector2(0, 0), 2.0, Color(1.0, 1.0, 1.0, 0.2))

func _update_encounters() -> void:
	encounters += 1
