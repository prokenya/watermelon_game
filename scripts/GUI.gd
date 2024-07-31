extends Control
@onready var use = %use
@onready var pick_up = %pick_up

@onready var hp = %hp
var item_id
var control_id
@onready var gui = $"."
@onready var menu = $"../ui_b"
var is_paused = false
func preessed():
	if is_multiplayer_authority():
		if gui.visible == true:
			gui.visible = false;$"../../..".set_physics_process(false)
			menu.visible = true
		else: gui.visible = true;menu.visible = false;$"../../..".set_physics_process(true)
		is_paused = not is_paused
		get_tree().paused = is_paused

func _ready():
	Event.connect("usev",visus)
	Event.connect("menu",preessed)
	Event.connect("control", ds_control)

func _process(delta):
	hp.text = "HP:" + str(Event.hp_char)

func ds_control(id):
	if id != 0:
		queue_free()

func visus(vis,item_id,control):
	pick_up.visible = vis
	use.visible = vis
	item_id = item_id
	control_id = control

func _on_touch_screen_button_pressed():
	Event.emit_signal("jump")


func _on_fire_pressed():
	if control_id != -1:
		Event.emit_signal("control",control_id)
		Event.control_id = control_id
		print(control_id)
	Event.emit_signal("fire")
