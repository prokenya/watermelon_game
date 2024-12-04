extends CharacterBody3D

@onready var Cam = $Head as Node3D

@export var mouseSensibility = 0.01
var mouse_relative_x = 0
var mouse_relative_y = 0

@export var padSensibility = 0.02

## How fast are we when we sprint
@export var SPEED_SPRINT = 42.0

## How fast are we normally
@export var SPEED_NORMAL = 12.0
var SPEED = SPEED_NORMAL

## How high can we jump
@export var JUMP_VELOCITY = 4.0

## If this is false, we can only jump when we're on the floor.
## A bit like you're used to from normal reality.
@export var CAN_JUMP_IN_AIR = true

## Head bob variables
## This also is used for footsteps
@export var HEAD_BOB_FREQ = 2.4
## Head bob variables
@export var HEAD_BOB_AMP = 0.1
var t_bob = 0.0

## Enables footsteps on each head bob.
@export var footstepsEnabled = true

## If you want your own audio samples to be played,
## you can replace them here.
@export var customFootstepSamples : Array[AudioStream] = []

## Before activating this, add "lookLeft", "lookRight", "lookUp","lookDown" in the input map
@export var useGamePad = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

## replay a players movement when there is no movement for a while
@export var activateAutopilot = false
var autoPilot : bool = false
var autoPilot_timer_ms : int = 1000 * 60 * 2
var autoPilot_recordtimer_ms : int = 1000
var autoPilot_last_ms : int = 0

var autoPilot_minElements : int = 60
var autoPilotBuffer_maxElements : int = 30 * 60
var autoPilotBuffer_velocity : Array = []
var autoPilotBuffer_rotation : Array = []
var autoPilotBuffer_head_rotation : Array = [] 
var autoPilotBuffer_jump : Array = []
var autoPilot_index : int = 0

var footSteps_toggle_1 : bool = false
var footSteps_toggle_2 : bool = false
	
func add_input_key(action, key):
	var new_input = InputEventKey.new()
	new_input.keycode = key
	if not InputMap.get_actions().count(action):
		InputMap.add_action(action)
	for a in InputMap.action_get_events(action):
		if a.keycode == new_input.keycode:
			# stop if there is already an action with same key
			return
	InputMap.action_add_event(action,new_input)
	
func create_input_map():
	add_input_key("moveForward", KEY_W)
	add_input_key("moveForward", KEY_UP)
	add_input_key("moveLeft", KEY_A)
	add_input_key("moveLeft", KEY_LEFT)
	add_input_key("moveRight", KEY_D)
	add_input_key("moveRight", KEY_RIGHT)
	add_input_key("moveBackward", KEY_S)
	add_input_key("moveBackward", KEY_DOWN)
	add_input_key("sprint", KEY_SHIFT)
	add_input_key("Jump", KEY_SPACE)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	autoPilot_last_ms = Time.get_ticks_msec()
	create_input_map()
	if footstepsEnabled:
		if customFootstepSamples.size() > 0:
			var audioStreamRandomizer : AudioStreamRandomizer = $footsteps.stream
			for i in range(audioStreamRandomizer.streams_count):
				audioStreamRandomizer.remove_stream(i)
			for i in range(customFootstepSamples.size()):
				audioStreamRandomizer.add_stream(i, customFootstepSamples[i])
				
var enable_push_rigidbody = true
var push_force = 1.0

func _push_rigidbody() -> void:
	if !enable_push_rigidbody: return

	var slideCollision
	for i in get_slide_collision_count():
		slideCollision = get_slide_collision(i)

	if slideCollision == null:
		return

	for i in slideCollision.get_collision_count():
		var collider = slideCollision.get_collider(i)
		if collider is RigidBody3D:
			collider.apply_central_impulse(-slideCollision.get_normal(i) * push_force)

func _physics_process(delta):
	var physics_state = PhysicsServer3D.body_get_direct_state(self.get_rid());
	var current_gravity = physics_state.get_total_gravity()

	# Calculate the players "up" direction and plane
	var up_player = global_transform.basis.y

	if not is_on_floor() or current_gravity.normalized() != up_direction.inverse():
		gravity = gravity * 0.9 + 0.1 * current_gravity
		velocity += (gravity * delta)

	# remember if we jump for autopilot
	var isJumping = false
	
	# Handle Jump.
	if Input.is_action_just_pressed("Jump"):
		# either we are on the floor, or we can jump in air
		if is_on_floor() or CAN_JUMP_IN_AIR:
			velocity.y = JUMP_VELOCITY
			isJumping = true

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if useGamePad:
		var look_dir = Input.get_vector("lookLeft", "lookRight", "lookUp","lookDown")
		rotation.y -= look_dir.x * padSensibility
		Cam.rotation.x -= look_dir.y * padSensibility
		Cam.rotation.x = clamp(Cam.rotation.x, deg_to_rad(-90), deg_to_rad(90) )

		if look_dir.x != 0 or look_dir.y != 0 or input_dir.x != 0 or input_dir.y != 0:
			autoPilot_last_ms = Time.get_ticks_msec()

	if activateAutopilot and Time.get_ticks_msec() - autoPilot_last_ms > autoPilot_timer_ms:
		autoPilot = is_on_floor()
	else:
		autoPilot = false

	if autoPilot:
		var n = autoPilotBuffer_velocity.size()
		if n > autoPilot_minElements:
			velocity = autoPilotBuffer_velocity[autoPilot_index % n] * 0.5
			rotation = rotation.slerp(autoPilotBuffer_rotation[autoPilot_index % n], 0.05)
			Cam.rotation = Cam.rotation * 0.99 + 0.01 * autoPilotBuffer_head_rotation[autoPilot_index % n]
		else:
			velocity.z = SPEED_NORMAL * -1

		var recordJump = autoPilotBuffer_jump[autoPilot_index % n]
		velocity.y = JUMP_VELOCITY if recordJump else 0.0

		autoPilot_index = (autoPilot_index + 1) % n
	elif Time.get_ticks_msec() - autoPilot_last_ms < autoPilot_recordtimer_ms:
		autoPilotBuffer_jump.push_back(isJumping)
		autoPilotBuffer_velocity.push_back(velocity)
		autoPilotBuffer_rotation.push_back(rotation)
		autoPilotBuffer_head_rotation.push_back(Cam.rotation)
		if autoPilotBuffer_velocity.size() > autoPilotBuffer_maxElements:
			var n = autoPilotBuffer_velocity.size()
			var from = max(0, n - autoPilotBuffer_maxElements)
			autoPilotBuffer_velocity.slice(from)
			autoPilotBuffer_rotation.slice(from)
			autoPilotBuffer_head_rotation.slice(from)
			autoPilotBuffer_jump.slice(from)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	var bob:Vector3 = _headbob(t_bob)
	Cam.transform.origin = bob
	
	if footstepsEnabled:
		footSteps_toggle_1 = abs(sin(t_bob * HEAD_BOB_FREQ)) < 0.1
			
		if abs(sin(t_bob * HEAD_BOB_FREQ)) > 0.2:
			footSteps_toggle_2 = true
		
		if footSteps_toggle_1 and footSteps_toggle_2:
			$footsteps.play()
			footSteps_toggle_2 = false
		
	move_and_slide()
	_push_rigidbody()

func _input(event):
	if autoPilot:
			rotation = Vector3(0,0,0)
			self.transform.basis = Basis(Quaternion(0,0,0,1))
			rotation = Vector3(0,0,0)
			Cam.rotation = Vector3(0,0,0)
			autoPilot = false

	autoPilot_last_ms = Time.get_ticks_msec()
	
	if Input.is_action_pressed("sprint"):
		SPEED = SPEED_SPRINT
	else:
		SPEED = SPEED_NORMAL

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouseSensibility
		Cam.rotation.x -= event.relative.y * mouseSensibility
		Cam.rotation.x = clamp(Cam.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

	if event is InputEventMouseButton:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventKey:
		var kcm = event.get_keycode_with_modifiers()
		if kcm == KEY_ESCAPE && event.pressed == false:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				get_tree().quit()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = abs(sin(time * HEAD_BOB_FREQ) * HEAD_BOB_AMP)
	pos.x = cos(time * HEAD_BOB_FREQ / 2) * HEAD_BOB_AMP
	return pos
