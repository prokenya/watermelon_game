extends CanvasLayer

func _ready():
	node_to_node.play("fade_in")
var id
@onready var node_to_node = $"Control/n-2-n"
var level2  = preload("res://scen/main_test_s.tscn")
var level1 = preload("res://demo/Demo.tscn")
func _on_play_pressed():
	id = 0
	node_to_node.play("fade_out")

func _on_n_2n_animation_finished(anim_name):
	if anim_name == "fade_out":
		if id == 0:
			get_tree().change_scene_to_packed(level1)
		if id == 1:
			get_tree().change_scene_to_packed(level2)


func _on_play_ml_pressed():
	id = 1
	node_to_node.play("fade_out")


func _on_credits_pressed():
	$Control/menu_0.visible = false
	$Control/PanelContainer.visible = true
	$Control/CanvasLayer2.visible = true
