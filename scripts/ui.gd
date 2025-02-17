extends CanvasLayer

@onready var menu: CanvasLayer = $ui_b
@onready var gui: CanvasLayer = $gui


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Event.connect("menu",pressed)


var is_paused = false
func pressed():
	if gui.visible == true:
		gui.visible = false
		menu.visible = true
	else:
		gui.visible = true
		menu.visible = false
	is_paused = not is_paused
	Event.not_move_gui = is_paused
