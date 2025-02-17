extends CharacterBody3D

@onready var Cam = $Head as Node3D

@export var mouseSensibility = 0.01
var mouse_relative_x = 0
var mouse_relative_y = 0

@export var padSensibility = 0.02

## How fast are we when we sprint
@export var SPEED_SPRINT = 12.0

## How fast are we normally
@export var SPEED_NORMAL = 4.0

@export var control_id: int = -170
@export var controller_id:int = -1
@export var controller_mpid:int = -1
var controlled_object_type:String = "freecam"
@export var control_item_id: int = -170

var camera_rotation_direction: Vector3

## inertia on speed change[br][br]
## [color=yellow]note:[/color] this is not the inertia on the movement of the body,
## only how fast the speed changes. Check "Intertia Strength".
@export_range(0.0,1.0) var SPEED_INTERTIA = 0.99
var SPEED_GOAL = SPEED_NORMAL
var SPEED : float = 0.0

## Before activating this, add "lookLeft", "lookRight", "lookUp","lookDown" in the input map
@export var useGamePad = false

var direction : Vector3 = Vector3(0,0,0)
## intertia on the movement of the body.[br]
## 0.0 is no inertia and direct response.[br]
## 0.95 feels like we are floating.[br]
## 1.0 would be no movement at all, that's why maximum is 0.999
@export_range(0.0,0.999) var intertia_strength = 0.95

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var footSteps_toggle_1 : bool = false
var footSteps_toggle_2 : bool = false
	
func add_input_key(action, key):
	var new_input = InputEventKey.new()
	new_input.keycode = key
	if not InputMap.get_actions().count(action):
		InputMap.add_action(action)
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
	add_input_key("moveUp", KEY_E)
	add_input_key("moveDown", KEY_Q)
	add_input_key("sprint", KEY_SHIFT)


@onready var camera_3d: Camera3D = $Head/Camera3d

func _ready():
	Event.connect("menu",pressed)
	Event.connect("update_control", apply_control)
	create_input_map()
func apply_control(control_info:Dictionary):
	if control_info["control_id"] == control_item_id:
		print("sdda")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		self.position = Event.playernode.position
		controller_id = control_info["controller_id"]
		control_id = control_info["control_id"]
		controller_mpid = control_info["multiplayer_index"]
		camera_3d.current = true
	else:
		control_id = -170
		controller_id = -1
		controller_mpid = -1
	apply_control_sync.rpc(control_id,controller_id,controller_mpid)

@rpc("any_peer","call_remote","reliable")
func apply_control_sync(c_id,cll_id,cll_mpid):
	control_id = c_id
	controller_id = cll_id
	controller_mpid = cll_mpid

func _physics_process(_delta):
	if controller_id == -1:
		return
	SPEED = SPEED * (1.0 - SPEED_INTERTIA) + SPEED_GOAL * SPEED_INTERTIA
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Vector2.ZERO
	var up_down_dir = Vector2.ZERO
	#if Event.platform == "PC":
	input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	up_down_dir = Input.get_action_strength("moveUp") - Input.get_action_strength("moveDown")
	var correctionAxis = Vector3(0,1,0);
	var correctionAngle = deg_to_rad(0);
	var new_direction = (Cam.global_transform.basis * Vector3(input_dir.x, up_down_dir, input_dir.y)).normalized()
	direction = direction.lerp(new_direction, 1.0 - intertia_strength);
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if useGamePad:
		var look_dir = Input.get_vector("lookLeft", "lookRight", "lookUp","lookDown")
		rotation.y -= look_dir.x * padSensibility
		Cam.rotation.x -= look_dir.y * padSensibility
		Cam.rotation.x = clamp(Cam.rotation.x, deg_to_rad(-90), deg_to_rad(90) )

	move_and_slide()
@onready var gui = self
@onready var menu = $".."
var is_paused = false
func pressed():
	if gui.visible == true:
		gui.visible = false
		menu.visible = true
	else:
		gui.visible = true
		menu.visible = false
	is_paused = not is_paused
	Event.not_move_gui = is_paused


func _input(event):
	if controller_id == -1:
		return
	if Event.platform != "PC":
		mobile_rotate_camera(event)
		return
	if Input.is_action_pressed("sprint"):
		SPEED_GOAL = SPEED_SPRINT
	else:
		SPEED_GOAL = SPEED_NORMAL

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
var tracked_touch_index = -1
var touch_start_position
var sensitivity = Event.setings.sensitivity
var current_rotation: Vector2
func mobile_rotate_camera(event):
	if Event.not_move_gui:
		print("dsad")
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if tracked_touch_index == -1:
				# Запоминаем первый палец
				touch_start_position = event.position
				tracked_touch_index = event.index
		elif event.index == tracked_touch_index:
			tracked_touch_index = -1
		
	# Обработка перетаскивания
	if event is InputEventScreenDrag:
		# Проверяем, отслеживается ли палец
		if event.index != tracked_touch_index:
			return
		else:
			# Рассчитываем и применяем изменение
			var delta = event.position - touch_start_position
			delta *= -1
			_rotate_camera(delta)
			touch_start_position = event.position
	# Обработка джойстика
	if event is InputEventJoypadMotion:
		_rotate_camera(Vector2(event.axis_value(0), event.axis_value(1)) * Event.setings.sensitivity)
func _rotate_camera(delta: Vector2):
	current_rotation += delta * sensitivity
	current_rotation.y = clamp(current_rotation.y, -90, 90)
	rotation_degrees.y = current_rotation.x
	self.rotation_degrees.x = current_rotation.y
