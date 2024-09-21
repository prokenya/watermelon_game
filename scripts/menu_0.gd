extends CanvasLayer

func _ready():
	node_to_node.play("fade_in")

var id
@onready var node_to_node = $"Control/n-2-n"
func _on_play_pressed():
	id = 0
	node_to_node.play("fade_out")

func _on_n_2n_animation_finished(anim_name):
	if anim_name == "fade_out":
		$Control/menu_0.visible = false
		$Control/select_level.visible = true
		node_to_node.play("fade_in")

func _on_credits_pressed():
	$Control/menu_0.visible = false
	$Control/PanelContainer.visible = true
	$Control/CanvasLayer2.visible = true
