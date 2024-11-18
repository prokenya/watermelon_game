extends CharacterBody3D

enum State { IDLE, WALK }
var state: State = State.IDLE
@export var hp: int = 100
@export var SPEED: float = 3.0
@export var JUMP_VELOCITY: float = 3.5
var user_prefs: UserPref
var last_position: Vector3
@onready var camera = $Node3D/Camera3D
@onready var shaking_anim = $animation_player
@onready var footstep_audio = $footstep
@onready var playeranim_gui = $Control_charapter/CanvasLayer/playeranim_gui
@onready var head = $Node3D
@onready var hand = $Node3D/hand
@onready var ray_cast_3d = $Node3D/Camera3D/RayCast3D
var picked_item_id: int
var picked_item: Object
var active_item
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera_3d: Camera3D = $Node3D/Camera3D
@onready var guinode: CanvasLayer = $Control_charapter/gui
@onready var mpp: MPPlayer
@onready var namee: Label3D = $name


var cam_ch: bool
var cam_shid: int = 0
var freejump: bool
var sensitivity: float
var tracked_touch_index: int = -1
var touch_start_position: Vector2
var current_rotation: Vector2
var dragging: bool = false
var active_item_id:int

var picked_item_control:int =-1
@export var control_item_id:int
var picked_controlled_object_type:String
var picked_controller_id:int = -1
var active_gui

func _ready():
	if Event.is_multiplayer:
		mpp = get_parent()
		mpp.handshake_ready.connect(_on_handshake_ready)
	user_prefs = UserPref.load_or_create()
	_apply_user_prefs()
	Event.connect("charapter_op", _apply_user_prefs)
	Event.connect("jump",_on_touch_screen_button_pressed)
	Event.connect("_active_item",_active_item)
	Event.connect("pick_up",pick_up)
	Event.connect("drop_item",drop_item)
	Event.connect("update_control",apply_control)
	last_position = position
	Event.control_id_counter += 1
	control_item_id = Event.control_id_counter
	if is_multiplayer_authority():
		if Event.is_multiplayer:
			Event.mpp_index = mpp.player_index
		Event.set_control({
			"control_id": control_item_id,
			"controller_id":control_item_id,
			"controlled_object_type":"player",
			"multiplayer_index":Event.mpp_index
			})

var gui = {
	"player": preload("res://scen/gui/character_gui.tscn"),
	"drone": preload("res://scen/gui/drone_gui.tscn")
}

var current_gui_type: String = ""

func apply_control(control_info: Dictionary):
	if is_multiplayer_authority():
		print(control_info)
		print(control_item_id)
		if control_info["control_id"] == control_item_id:
			camera_3d.current = true
			
		var new_gui_type = control_info["controlled_object_type"]
		
		if current_gui_type == new_gui_type:
			return
		
		for child in guinode.get_children():
			child.queue_free()

		current_gui_type = new_gui_type
		
		var gui_scene = gui.get(new_gui_type, null)
		if gui_scene:
			guinode.add_child(gui_scene.instantiate())

#inventory
func _active_item(id):
	if Event.is_multiplayer == false:
		if hand.get_children() != null and active_item_id != id:
			for child in hand.get_children():
				hand.remove_child(child)
				child.queue_free()
		var data = {
			"spawn_obj_id": id,
			"obj_position": Vector3(0,0,0),
			"obj_scale": Vector3(0.7, 0.7, 0.7),
			"amount": 1,
			"impulse": Vector3(0, 0, 0),
			"pl_id": Event.mpp_index,
			"spawn_parent":hand,
			"inventory": true
			}
		if id != -1 and active_item_id != id:
			Event.emit_signal("spawn_obj",data)
		active_item_id = id
	else:
		set_active_item(id) 


func pick_up(id):
	if Event.is_multiplayer == false:
		if picked_item != null:
			picked_item.queue_free()
			Event.emit_signal("add_item",picked_item_id,Event.mpp_index)
	else:
		mp_pick_up(id)

func drop_item(item_id,amount):
	if is_multiplayer_authority():
		var data = {
		"spawn_obj_id": item_id,
		"obj_position": hand.global_position + global_transform.basis.x,
		"obj_rotation": head.global_rotation,
		"obj_scale": Vector3(1, 1, 1),
		"amount": amount,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
		Event.emit_signal("spawn_obj",data)
func _apply_user_prefs():
	freejump = user_prefs.freejump_s
	sensitivity = user_prefs.sensitivity
	cam_ch = user_prefs.cam_ch
	var index = user_prefs.MSAA
	if user_prefs.infinite_hp == true:
		hp = 10000000
	else: hp = 100
	Event.hp_char = hp
	match index:
		0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1: get_viewport().msaa_3d = Viewport.MSAA_2X
		2: get_viewport().msaa_3d = Viewport.MSAA_4X
		3: get_viewport().msaa_3d = Viewport.MSAA_8X

func _process(delta: float):
	if position.distance_to(last_position) > 0.01:
		last_position = position
		_change_state(State.WALK)
		_play_footstep_anim()

	if ray_cast_3d.is_colliding():
		picked_item = ray_cast_3d.get_collider()
		if picked_item != null:
			if picked_item.get("item_id") != null:
				picked_item_id = picked_item.item_id
			else: picked_item_id = -1
			if picked_item.get("control_item_id") != null:
				picked_item_control = picked_item.get("control_item_id")
			else:
				picked_item_control = -1
			
			if picked_item.get("controlled_object_type") != null:
				picked_controlled_object_type = picked_item.get("controlled_object_type")
			else:
				picked_controlled_object_type = "null"
			if picked_item.get("controller_id") != null:
				picked_controller_id = picked_item.get("controller_id")
			else: picked_controller_id = -1
	else:
		picked_item_id = -1
		picked_item_control = -1
		picked_controller_id = -1
		picked_controlled_object_type = "null"


func _physics_process(delta: float):
	if is_multiplayer_authority():
		SimpleGrass.set_player_position(global_position)
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()

func _change_state(new_state: State):
	state = new_state

func _play_footstep_anim():
	if cam_ch == true and is_on_floor():
		if not shaking_anim.is_playing():
			shaking_anim.speed_scale = 3
			if cam_shid == 0:
				shaking_anim.play("cam_go_shaking_left")
			else:
				shaking_anim.play("cam_go_shaking_right")
func footstep():
	footstep_audio.play()
func _input(event: InputEvent):
	if not is_multiplayer_authority():
		return
	if Event.is_inventory_active == true:
		return  # Если инвентарь активен, не обрабатывать события для игрока
	if Event.move_gui == true:
		return
	if Event.control_info["control_id"] != control_item_id:
		return
	
	# Обработка касаний экрана
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
		_rotate_camera(Vector2(event.axis_value(0), event.axis_value(1)) * sensitivity)

func _rotate_camera(delta: Vector2):
	current_rotation += delta * sensitivity
	current_rotation.y = clamp(current_rotation.y, -90, 90)
	rotation_degrees.y = current_rotation.x
	head.rotation_degrees.x = current_rotation.y

func _on_touch_screen_button_pressed():
	if freejump or is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_area_3d_area_entered(area: Area3D):
	if area.is_in_group("damage"):
		hp -= area.get_parent().damage
		print(hp)
		playeranim_gui.play("damag")
		if hp <= 0:
			Event.emit_signal("back_s",1)
		Event.hp_char = hp
	

func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "cam_go_shaking_right":
		cam_shid = 0
	else:
		cam_shid = 1

## mplayer

func _on_handshake_ready(data):
	print(data)
	if data.get("name") != null:
		namee.text = data.get("name")

func set_active_item(id):
	if is_multiplayer_authority():
		var p_id = mpp.player_index
		#_active_item.rpc(id,p_id)
		mp_active_item.call_deferred(id,p_id)

#@rpc("any_peer", "call_local", "reliable")
func mp_active_item(id,p_id):
	if mpp.player_index == p_id:
		if hand.get_children() != null and active_item_id != id:
			for child in hand.get_children():
				hand.remove_child(child)
				child.queue_free()
		if id != -1 and active_item_id != id:
			active_item = InventoryManager.items[id][1].instantiate()
			active_item.position = hand.position
			hand.add_child(active_item)
		active_item_id = id

func mp_pick_up(id):
	pick_up_mp.rpc(id)

@rpc("any_peer", "call_local", "reliable")
func pick_up_mp(mp_id):
	if mp_id != -1:
		if mp_id == get_parent().player_index:
			if picked_item != null:
				picked_item.queue_free()
				Event.emit_signal("add_item",picked_item_id,mp_id)
	if mp_id == -1:
		if picked_item != null:
			picked_item.queue_free()
			Event.emit_signal("add_item",picked_item_id,mp_id)
