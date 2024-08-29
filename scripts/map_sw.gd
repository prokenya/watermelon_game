extends AnimationPlayer

@onready var node_to_node = %"n-2-n"
var idex:int
func back_s(id):
	get_tree().paused = false
	node_to_node.play("fade_out")
	idex = id

func _on_animation_finished(anim_name):
	if idex == 1:
		get_tree().change_scene_to_file("res://scen/gui/menu.tscn")

func _ready():
	Event.connect("back_s",back_s)
	node_to_node.play("fade_in")
