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
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var cam_ch: bool
var cam_shid: int = 0
var freejump: bool
var sensitivity: float
var tracked_touch_index: int = -1
var touch_start_position: Vector2
var current_rotation: Vector2
var dragging: bool = false
var active_item = null
var active_item_id:int = -1
var picked_item_control:int
@export var control_id:int
@onready var namee = $name

@onready var mpp: MPPlayer = get_parent()
func _ready():
	user_prefs = UserPref.load_or_create()
	_apply_user_prefs()
	mpp.handshake_ready.connect(_on_handshake_ready)
	Event.connect("charapter_op", _apply_user_prefs)
	Event.connect("control", ds_control)
	Event.connect("jump",_on_touch_screen_button_pressed)
	Event.connect("_active_item",set_active_item)
	Event.connect("pick_up",pick_up)
	Event.connect("drop_item",drop_item_s)
	last_position = position
	control_id = Event.control_item_id + 1
	Event.control_item_id = Event.control_item_id + 1
	if is_multiplayer_authority():
		Event.player_control_id = control_id
		Event.mpp_index = mpp.player_index
		Event.emit_signal("control",control_id,-1,mpp.player_index)
#inventory

func _on_handshake_ready(data):
	print(data)
	if data.get("name") != null:
		namee.text = data.get("name")

func set_active_item(id):
	if is_multiplayer_authority():
		var p_id = mpp.player_index
		_active_item.rpc(id,p_id)

@rpc("any_peer", "call_local", "reliable")
func _active_item(id,p_id):
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

func pick_up(id):
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

func drop_item_s(id,amount):
	if is_multiplayer_authority():
		var data = {
		"spawn_obj_id": id,
		"obj_position": hand.global_position + global_transform.basis.x,
		"obj_rotation": head.global_rotation,
		"obj_scale": Vector3(1, 1, 1),
		"amount": amount,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
		Event.emit_signal("spawn_obj",data)
		#var p_id = mpp.player_index
		#drop_item.rpc(id,amount,p_id)

#@rpc("any_peer", "call_local", "reliable")
#func drop_item(item_id,amount,p_id):
	#var dropped_item_scene
	#if mpp.player_index == p_id:
		#Event.spawn_item(item_id,hand.global_position + Vector3(0,1,0),
		#head.rotation,Vector3(0.4,0.4,0.4),amount,Vector3(0,0,0),Event.mpp_index)
		#match item_id:
			#0: dropped_item_scene = preload("res://scen/drop/drone.tscn")
			#1: dropped_item_scene = preload("res://scen/drop/ak_drop.tscn")
			#2: dropped_item_scene = preload("res://scen/drop/watermelon.tscn")
			#3: dropped_item_scene = preload("res://scen/drop/drone_exp.tscn")
		#for i in range(amount):
			#var dropped_item = dropped_item_scene.instantiate()
			#dropped_item.position = hand.global_position + global_transform.basis.x
			#dropped_item.rotation = head.global_rotation
			#get_parent().add_child(dropped_item)

func ds_control(id,item_id,player_id):
	if is_multiplayer_authority():
		if id == control_id:
			camera.current = true
		if id != control_id:
			$Control_charapter.add_child(preload("res://scen/gui/drone_gui.tscn").instantiate())
		if id == control_id and camera.current == false:
			$Control_charapter.add_child(preload("res://scen/gui/character_gui.tscn").instantiate())
			camera.current = true
			Event.control_id = control_id
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
			picked_item_id = picked_item.item_id
			if picked_item.item_id == 0 or picked_item.item_id == 3:
				picked_item_control = picked_item.control_item_id
			else:picked_item_control = -1
			#print("->",picked_item_control)
			Event.emit_signal("usev",true,picked_item_id,picked_item_control,mpp.player_index)
	else: 
		Event.emit_signal("usev",false,-1,-1,mpp.player_index)
func _physics_process(delta: float):
	SimpleGrass.set_player_position(global_position)
	if is_multiplayer_authority():
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
	if cam_ch == true and is_on_floor() and is_multiplayer_authority():
		if not shaking_anim.is_playing():
			shaking_anim.speed_scale = 3
			if cam_shid == 0:
				shaking_anim.play("cam_go_shaking_left")
			else:
				shaking_anim.play("cam_go_shaking_right")
func footstep():
	footstep_audio.play()
func _input(event: InputEvent):
	if is_multiplayer_authority():
		if control_id == Event.control_id:
			if Event.is_inventory_active == true:
				return  # Если инвентарь активен, не обрабатывать события для игрока
			if Event.move_gui == true:
				return
			
			if event is InputEventScreenTouch:
				if event.pressed:
					if tracked_touch_index == -1:
						tracked_touch_index = event.index
						touch_start_position = event.position
						dragging = true
				elif event.index == tracked_touch_index:
					tracked_touch_index = -1
					dragging = false
			if event is InputEventScreenDrag and event.index == tracked_touch_index:
				if dragging:
					# Пропускаем первый кадр, чтобы избежать резкого скачка
					dragging = false
					touch_start_position = event.position
				else:
					var delta = event.position - touch_start_position
					delta *= -1
					_rotate_camera(delta)
					touch_start_position = event.position


		if event is InputEventJoypadMotion:
			_rotate_camera(Vector2(event.axis_value(0), event.axis_value(1)) * sensitivity)

func _rotate_camera(delta: Vector2):
	current_rotation += delta * sensitivity
	current_rotation.y = clamp(current_rotation.y, -90, 90)
	rotation_degrees.y = current_rotation.x
	$Node3D.rotation_degrees.x = current_rotation.y

func _on_touch_screen_button_pressed():
	if freejump or is_on_floor() and is_multiplayer_authority():
		velocity.y = JUMP_VELOCITY

func _on_area_3d_area_entered(area: Area3D):
	if is_multiplayer_authority():
		if area.is_in_group("damage"):
			hp -= area.get_parent().damage
			playeranim_gui.play("damag")
			if hp <= 0:
				if multiplayer.is_server():
					playeranim_gui.play("damag")
				else:
					mpp.disconnect_player()
					mpp.despawn_node()
					get_tree().change_scene_to_file("res://scen/gui/menu.tscn")
					playeranim_gui.play("damag")
			Event.hp_char = hp
	

func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "cam_go_shaking_right":
		cam_shid = 0
	else:
		cam_shid = 1
