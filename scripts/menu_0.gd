extends CanvasLayer

func _ready():
	node_to_node.play("fade_in")
	Event.printc("загружено предметов:" + str(InventoryManager.items),Color.GREEN)
@onready var active_layer = [$Control/menu,$Control/select_level,$Control/settings,%credits]
@onready var menu_button: CanvasLayer = $Control/menub
var active_layer_id: = 0

var switchid:int
@onready var node_to_node = $"Control/n-2-n"


func play_anim(anim:String):
	node_to_node.play(anim)
	await node_to_node.animation_finished
	return true

func pressed(id):
	await play_anim("fade_out")
	active_layer[active_layer_id].visible = false
	active_layer_id = id
	active_layer[active_layer_id].visible = true
	play_anim("fade_in")
	menu_button.show()
	if id == 0:menu_button.hide()


func _on_multiplayer_pressed() -> void:
	await play_anim("fade_out")
	get_tree().change_scene_to_file("res://scen/gui/multi_play_core.tscn")

func _on_play_pressed():
	pressed(1)

func _on_settings_pressed() -> void:
	pressed(2)


func _on_credits_pressed() -> void:
	pressed(3)


func _on_menu_pressed() -> void:
	pressed(0)
