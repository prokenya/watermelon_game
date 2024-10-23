extends RigidBody3D

enum State { IDLE, FLY }
var state: State = State.IDLE
var hp: int = 100
const SPEED: float = 0.05
const JUMP_VELOCITY: float = 3.5
var user_prefs: UserPref
var last_position: Vector3
var item_id = 0

#drone anim
@onready var prop1 = $drone/MeshInstance3D2
@onready var prop2 = $drone/MeshInstance3D3
@onready var prop3 = $drone/MeshInstance3D4
@onready var prop4 = $drone/MeshInstance3D5
@onready var camera_3_person = $Camera3person
@onready var camera_1_person = $Camera1person

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var sensitivity: float
var tracked_touch_index: int = -1
var touch_start_position: Vector2
var current_rotation: Vector2
var dragging: bool = false
var value: float = 0
var global_t
@export var rotate_dir:Vector2
@export var input_dir:Vector2
@onready var debug_label = $"debug label"

var id_control: int = 0
var controller_id:int = -1
var controlled_object_type:String = "drone"
var controler_id_nosync:int = -1
@export var control_item_id: int
# Добавляем переменную для хранения направления вращения камеры
var camera_rotation_direction: Vector3

func _ready():
	user_prefs = UserPref.load_or_create()
	_apply_user_prefs()
	Event.connect("charapter_op", _apply_user_prefs)
	Event.connect("update_control", apply_control_drone)
	Event.connect("cam_1_3p",app_cam)
	Event.connect("reset_drone_pos",reset_drone_pos)
	last_position = position
	camera_rotation_direction = Vector3(0, 0, 1) # Инициализируем направление камеры вперед
	global_t = global_transform
	#if Event.is_multiplayer == true:
		#debug_label.visible = true

func apply_control_drone(control_info:Dictionary):
	if control_info["control_id"] == control_item_id:
		camera_1_person.current = true
		controller_id = control_info["controller_id"]
	

@rpc("any_peer", "call_local", "reliable")
func sync(c_id,id_c):
	controller_id = c_id
	id_control = id_c
	debug_label.text = "controller_id:"+str(controller_id)
	
func app_cam(cam,id):
	if control_item_id == id:
		if cam == true:
			camera_3_person.current = true
		else:
			camera_1_person.current = true
func _apply_user_prefs():
	sensitivity = user_prefs.sensitivity
	var index = user_prefs.MSAA
	if user_prefs.infinite_hp == true:
		hp = 10000000
	else: hp = 100
	match index:
		0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1: get_viewport().msaa_3d = Viewport.MSAA_2X
		2: get_viewport().msaa_3d = Viewport.MSAA_4X
		3: get_viewport().msaa_3d = Viewport.MSAA_8X
func reset_drone_pos():
	global_transform = global_t
func _process(delta: float):
	if position.distance_to(last_position) > 0.01:
		last_position = position
		_change_state(State.FLY)
	if control_item_id == Event.control_info["controller_id"]:
		Event.drone_speed = "m/c" + str(round(linear_velocity))
var impulse = Vector3()


@rpc("any_peer", "call_local")
func movedata(r_dir,i_dir):
	position = r_dir
	rotation = i_dir
	#if controler_id_nosync == -1:
		#print(rotate_dir)

func _physics_process(delta: float):
	if control_item_id == id_control:
		if Event.is_multiplayer == true:
				if controller_id == Event.mpp_index:
					rotate_dir = Input.get_vector("left_drone_r","right_drone_r","downd2","upd2")
					input_dir = Input.get_vector("ui_left_d", "ui_right_d", "ui_up_d", "ui_down_d")
					movedata.rpc(position,rotation)
				
		else: 
			rotate_dir = Input.get_vector("left_drone_r","right_drone_r","downd2","upd2")
			input_dir = Input.get_vector("ui_left_d", "ui_right_d", "ui_up_d", "ui_down_d")
		value = (rotate_dir[1])*10
		var current_rotation_speed = 2
		if rotate_dir[1] > 0:
			current_rotation_speed = value * 5
			var forward = global_transform.basis.y
			forward = forward.normalized()
			apply_central_impulse(forward * value * SPEED)
		else:
			current_rotation_speed = lerp(current_rotation_speed, 0, 10 * delta)
		prop1.rotation.y += current_rotation_speed * delta
		prop2.rotation.y += current_rotation_speed * -delta
		prop3.rotation.y += current_rotation_speed * delta
		prop4.rotation.y += current_rotation_speed * -delta
		#if current_rotation.x != 0:
			#rotate_y(deg_to_rad(current_rotation.x * 10 * delta))
			#current_rotation.x = 0
		if input_dir:
			if input_dir.length() > 0.01:
				rotate_object_local(Vector3(1,0,0), deg_to_rad(input_dir[1] * sensitivity * delta * 150))
				rotate_object_local(Vector3(0,0,1), deg_to_rad(-input_dir[0] * sensitivity * delta * 150))
		if rotate_dir:
			if rotate_dir.length() > 0.01:
				rotate_y(deg_to_rad(-rotate_dir[0] * sensitivity * delta * 150))
	if controller_id == -1 and multiplayer.is_server():
		movedata.rpc(position,rotation)


func _change_state(new_state: State):
	state = new_state

#func _input(event: InputEvent):
	#if id_control == 1:
		#if event is InputEventScreenTouch:
			#if event.pressed:
				#if tracked_touch_index == -1:
					#tracked_touch_index = event.index
					#touch_start_position = event.position
					#dragging = true
			#elif event.index == tracked_touch_index:
				#tracked_touch_index = -1
				#dragging = false
	#if id_control == 1:
		#if event is InputEventScreenDrag and event.index == tracked_touch_index:
			#if dragging:
				## Пропускаем первый кадр, чтобы избежать резкого скачка
				#dragging = false
				#touch_start_position = event.position
			#else:
				#var delta = event.position - touch_start_position
				#delta *= -1
				#_rotate_camera(delta)
				#touch_start_position = event.position
#
	#if event is InputEventJoypadMotion:
		#_rotate_camera(Vector2(event.axis_value(0), event.axis_value(1)) * sensitivity)
#
#func _rotate_camera(delta: Vector2):
	#current_rotation += delta * sensitivity
	## Apply rotation to the RigidBody3D
	##apply_torque_impulse(Vector3(0,current_rotation.x,0))
	##current_rotation.x = 0
