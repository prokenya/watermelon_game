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
	player_node = get_parent().get_parent().get_parent()


func _process(delta):
	hp.text = "HP:" + str(Event.hp_char)
	pos.text = "pos:" + str(round(player_node.position))
	update_ids()

func update_ids():
	item_id = player_node.picked_item_id
	control_id = player_node.picked_item_control
	#print(control_id)
	if item_id == -1:
		pick_up.visible = false
	else:pick_up.visible = true

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
	Event.emit_signal("on_fire",mpp)


func _on_pick_up_pressed():
	#print(Event.avable_items_id,"\n",item_id)
	if item_id in Event.avable_items_id or Event.avable_items_id[0] == -2:
		if Event.is_multiplayer == true:
			Event.emit_signal("pick_up",Event.mpp_index)
		else:
			Event.emit_signal("pick_up",-1)
