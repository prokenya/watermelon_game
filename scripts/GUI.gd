extends Control

@onready var use = $use
@onready var pick_up: Button = $pick_up
@onready var hp = $hp
var item_id
var control_id
@onready var gui = $"."
@onready var menu = $"../../ui_b"
@onready var pos: Label = $pos
@onready var player_node
@onready var hints: Array = $hints.get_children()
@onready var elements_to_del_mobile:Array = [$"Virtual Joystick",$VBoxContainer,$VBoxContainer2,pick_up,$Button]
@onready var elements_to_del_PC:Array = [$hints]

func _ready():
	if Event.platform == "PC":
		for item in elements_to_del_mobile:
			item.queue_free()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		for item in elements_to_del_PC:
			item.queue_free()
	player_node = get_parent().get_parent().get_parent()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SLASH):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Event.emit_signal("menu")
	if Event.platform == "PC":
		if Input.is_action_just_pressed("jump_move"):
			_on_touch_screen_button_pressed()
		if Input.is_action_just_pressed("interact"):
			_on_fire_pressed()
		if Input.is_action_just_pressed("F-KEY") and item_id != -1:
			_on_pick_up_pressed()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !Event.not_move_gui:
			Event.emit_signal("on_fire",Event.mpp_index)

func _process(delta):
	hp.text = "HP:" + str(Event.hp_char)
	pos.text = "pos:" + str(round(player_node.position))
	update_ids()

func update_ids():
	item_id = player_node.picked_item_id
	control_id = player_node.picked_item_control
	#print(control_id)
	if Event.platform != "PC":
		if item_id == -1:
			pick_up.visible = false
		else:
			pick_up.visible = true
	else:
		if item_id != -1:
			hints[0].visible = true
		else:
			hints[0].visible = false
		if control_id != -1:
			hints[1].visible = true
		else:
			hints[1].visible = false
	
func _on_touch_screen_button_pressed():
	Event.emit_signal("jump")


func _on_fire_pressed():
	var mpp = -1
	if Event.is_multiplayer == true:
		mpp = player_node.mpp.player_index
	if control_id != -1 and player_node.picked_controller_id == -1:
		var data = {
		"control_id": control_id,
		"controller_id":player_node.control_item_id,
		"controlled_object_type":player_node.picked_controlled_object_type,
		"multiplayer_index":mpp
		}
		Event.set_control(data)
		print("Applying control for ID:",control_id)
	if Event.platform != "PC":
		Event.emit_signal("on_fire",Event.mpp_index)

func _on_pick_up_pressed():
	if item_id == -1:
		return
	#print(Event.avable_items_id,"\n",item_id)
	if item_id in Event.avable_items_id or Event.avable_items_id[0] == -2:
		if Event.is_multiplayer == true:
			Event.emit_signal("pick_up",Event.mpp_index)
			
		else:
			Event.emit_signal("pick_up",-1)
