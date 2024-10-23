extends Control

@onready var use = $use
@onready var pick_up = $pick_up
@onready var hp = $hp
var item_id
var control_id
@onready var gui = $"."
@onready var menu = $"../../ui_b"
@onready var pos: Label = $pos
@onready var player_node
var is_paused = false
func pressed():
	if gui.visible == true:
		gui.visible = false
		menu.visible = true
	else:
		gui.visible = true
		menu.visible = false
	is_paused = not is_paused
	Event.move_gui = is_paused

func _ready():
	Event.connect("menu", pressed)
	Event.connect("usev", visus)
	player_node = get_parent().get_parent().get_parent()


func _process(delta):
	hp.text = "HP:" + str(Event.hp_char)
	pos.text = "pos:" + str(round(player_node.position))

func ds_control(id,item_id,player_id):
	if id != Event.player_control_id:
		queue_free()

func visus(vis,item_id,control,mp_id):
	if mp_id != -1:
		if mp_id == player_node.mpp.player_index:
			pick_up.visible = vis
			use.visible = vis
			item_id = item_id
			control_id = control
	else:
		pick_up.visible = vis
		use.visible = vis
		item_id = item_id
		control_id = control

func _on_touch_screen_button_pressed():
	Event.emit_signal("jump")


func _on_fire_pressed():
	var mpp = -1
	if Event.is_multiplayer == true:
		mpp = player_node.mpp.player_index
	if control_id != -1:
		var data = {
		"control_id": control_id,
		"controller_id":player_node.control_item_id,
		"controlled_object_type":player_node.picked_controlled_object_type,
		"multiplayer_index":-1
		}
		Event.set_control(data)
		print("Applying control for ID:",control_id)
	Event.emit_signal("on_fire",mpp)


func _on_pick_up_pressed():
	if Event.is_multiplayer == true:
		Event.emit_signal("pick_up",get_parent().get_parent().mpp.player_index)
	else:
		Event.emit_signal("pick_up",-1)
