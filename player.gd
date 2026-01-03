extends CharacterBody3D

@export var hasEscaped := false

@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D
@onready var coordinates: Label = $head/Camera3D/GameOverlay/Coordinates
@onready var crosshair: CenterContainer = $head/Camera3D/GameOverlay/Crosshair
@onready var instruction: Label = $head/Camera3D/GameOverlay/Instruction

const SPEED = 3.0
const ACCELERATION = 10.0
const SPRINT_SPEED = 6.0
const SPRINT_TIME = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5

var walk_bob_speed := 8.0
var walk_bob_amount := 0.02
var walk_sway_amount := 0.01

var bob_time := 0.0
var base_head_position: Vector3
var sprint_cooldown = 5.0

var isPaused := false
var isDead := false
var encounters := 0
var walked := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crosshair.queue_redraw()
	base_head_position = camera.position
	# Scene transistion
	var tween = create_tween()
	tween.tween_property($head/Camera3D/GameOverlay/BlackOverlay, 'color', Color(0.0, 0.0, 0.0, 0.0), 2.0)
	tween.tween_property($head/Camera3D/GameOverlay/BlackOverlay, 'visible', false, 0.1)

func _physics_process(delta: float) -> void:
	# Display the coordinates:
	coordinates.text = "X: {0} | Y: {1} | Z: {2}".format([str(round(position.x)), str(round(position.y)), str(round(position.z))])
	$head/Camera3D/GameOverlay/SprintBar.value = sprint_cooldown
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
	var target_speed: float = SPEED # Walking
	var is_falling := velocity.y < -10.0
	
	if direction:
		if Input.is_action_pressed('sprint') and sprint_cooldown > delta: # Sprinting
			sprint_cooldown = max(sprint_cooldown - delta, 0.0)
			target_speed = SPRINT_SPEED
			if $WalkingAudio.pitch_scale < 2: # Transistion to sprint
				$WalkingAudio.pitch_scale = lerp($WalkingAudio.pitch_scale, 2.0, 0.1 * delta)
				$WalkingAudio.volume_db = lerp($WalkingAudio.volume_db, 3.0, 0.1 * delta)
			if camera.fov < 90.0 and not is_falling:
				camera.fov = lerp(camera.fov, 90.0, 5.0 * delta)
		else:
			sprint_cooldown = min(sprint_cooldown + delta * 0.25, SPRINT_TIME)
			if $WalkingAudio.pitch_scale > 1.25: # Transistion to walk
				$WalkingAudio.pitch_scale = lerp($WalkingAudio.pitch_scale, 1.25, 0.1 * delta)
				$WalkingAudio.volume_db = lerp($WalkingAudio.volume_db, 0.0, 0.1 * delta)
			if camera.fov > 75.0 and not is_falling:
				camera.fov = lerp(camera.fov, 75.0, 5.0 * delta)
		if not $WalkingAudio.playing:
			$WalkingAudio.play()
	else: # Stopping
		sprint_cooldown = min(sprint_cooldown + delta * 0.5, SPRINT_TIME)
		target_speed = 0.0
		if $WalkingAudio.playing:
			$WalkingAudio.stop()
		if camera.fov > 75.0 and not is_falling:
			camera.fov = lerp(camera.fov, 75.0, 5.0 * delta)
			
	if is_falling:
		camera.fov = lerp(camera.fov, velocity.y * -0.3 + 75, delta * 5.0)
	# Update velocity smoothly.
	velocity.x = lerp(velocity.x, direction.x * target_speed, delta * ACCELERATION)
	velocity.z = lerp(velocity.z, direction.z * target_speed, delta * ACCELERATION)
	move_and_slide()
	
	# Camera shake
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_walking := horizontal_speed > 0.1 and is_on_floor() and not isPaused and not isDead
	if is_walking:
		bob_time += delta * walk_bob_speed
		# Vertical bob
		var bob_y = sin(bob_time * 2.0) * walk_bob_amount * horizontal_speed
		# Horizontal sway
		var bob_x = sin(bob_time) * walk_sway_amount * horizontal_speed
		# Update camera position smoothly
		camera.position = camera.position.lerp(
			base_head_position + Vector3(bob_x, bob_y, 0),
			10.0 * delta
		)
	else:
		# Reset camera
		bob_time = 0.0
		camera.position = camera.position.lerp(base_head_position, 8.0 * delta)
		camera.rotation.z = lerp(camera.rotation.z, 0.0, 6.0 * delta)
	# Camera rotation
	camera.rotation.z = lerp(
		head.rotation.z,
		sin(bob_time) * 0.01,
		6.0 * delta
	)
	
	if hasEscaped:
		if $head/Camera3D/Effects.visible:
			$head/Camera3D/Effects.visible = false
		return
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
