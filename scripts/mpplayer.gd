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
var id_control: int = 0
var active_item = null
var picked_item_control:int
var control:bool = false
@onready var mpp: MPPlayer = get_parent()
func _ready():
	user_prefs = UserPref.load_or_create()
	_apply_user_prefs()
	Event.connect("charapter_op", _apply_user_prefs)
	Event.connect("control", ds_control)
	Event.connect("fire",_on_fire_pressed)
	Event.connect("jump",_on_touch_screen_button_pressed)
	Event.connect("_active_item",set_active_item)
	Event.connect("pick_up",pick_up)
	Event.connect("drop_item",drop_item)
	last_position = position
	if is_multiplayer_authority():
		camera.current = true
		ds_control(0)
#inventory

func set_active_item(id):
	if is_multiplayer_authority():
		var p_id = mpp.player_index
		_active_item.rpc(id,p_id)

@rpc("any_peer", "call_local", "reliable")
func _active_item(id,p_id):
	if mpp.player_index == p_id:
		if active_item != null:
			hand.remove_child(active_item)
			active_item.queue_free()
		if id == 0:
			active_item = preload("res://scen/drone_inv.tscn").instantiate()
			active_item.position = hand.position
		elif id == 1:
			active_item = preload("res://scen/watermelon_gun.tscn").instantiate()
			active_item.position = hand.position
		elif id == 2:
			active_item = preload("res://scen/watermelon_inv.tscn").instantiate()
			active_item.position = hand.position
		else:
			active_item = null
			return
		hand.add_child(active_item)

func pick_up():
	if picked_item != null:
		picked_item.queue_free()
		Event.emit_signal("add_item",picked_item_id)

func drop_item(item_id,amount):
	var dropped_item_scene
	match item_id:
		0: dropped_item_scene = preload("res://scen/drop/drone.tscn")
		1: dropped_item_scene = preload("res://scen/drop/ak_drop.tscn")
		2: dropped_item_scene = preload("res://scen/drop/watermelon.tscn")
		3: dropped_item_scene = preload("res://scen/drop/drone_exp.tscn")
	for i in range(amount):
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.position = hand.global_position
		dropped_item.rotation = head.global_rotation
		get_tree().root.add_child(dropped_item)

func ds_control(id):
	id_control = id
	if id != 0 and control == true:
		control = false
		camera.current = false
		$Control_charapter.add_child(preload("res://scen/drone_gui.tscn").instantiate())
	if id == 0 and control == false:
		$Control_charapter.add_child(preload("res://scen/character_gui.tscn").instantiate())
		control = true
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
			#print("->",picked_item_id)
			Event.emit_signal("usev",true,picked_item_id,picked_item_control)
	else: 
		Event.emit_signal("usev",false,-1,-1)
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
		if id_control == 0:
			if Event.is_inventory_active == true:
				return  # Если инвентарь активен, не обрабатывать события для игрока
			
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
	if freejump or is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_fire_pressed():
	Event.emit_signal("_on_fire_pressed")
func _on_area_3d_area_entered(area: Area3D):
	if area.editor_description == "hurt":
		hp -= 10
		playeranim_gui.play("damag")
	if area.editor_description == "hurt1x":
		hp -= 100
		playeranim_gui.play("damag")
	if area.editor_description == "hurt1m" or area.editor_description == "0":
		hp -= 150
		playeranim_gui.play("damag")
	if hp <= 0:
		Event.emit_signal("back_s",1)
		print("hurt1x")
		playeranim_gui.play("damag")
	Event.hp_char = hp
	

func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "cam_go_shaking_right":
		cam_shid = 0
	else:
		cam_shid = 1

