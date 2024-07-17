extends Control

@onready var sensitivity_slider = %sensitivity_Slider
@onready var grass_move = %grass_move
@onready var grass_i = %grass_i
@onready var shadows = %shadows

func _ready():
	user_prefs = UserPref.load_or_create()
	if sensitivity_slider:
		sensitivity_slider.value = user_prefs.sensitivity
		Event.emit_signal("charapter_op")
	if grass_move:
		grass_move.button_pressed = user_prefs.grass_move
	if grass_i:
		grass_i.button_pressed = user_prefs.grass_i
	if shadows:
		shadows.button_pressed = user_prefs.shadows
	

var user_prefs: UserPref

func _on_shadows_toggled(toggled_on):
	if user_prefs:
		user_prefs.shadows = toggled_on
		user_prefs.save()
		Event.emit_signal("world_s_op")

func _on_grass_move_toggled(toggled_on):
	if user_prefs:
		user_prefs.grass_move = toggled_on
		user_prefs.save()
		Event.emit_signal("world_s_op")

func _on_sensitivity_slider_value_changed(value):
	if user_prefs:
		user_prefs.sensitivity = value
		user_prefs.save()
		Event.emit_signal("charapter_op")

func _on_grass_i_toggled(toggled_on):
	if user_prefs:
		user_prefs.grass_i = toggled_on
		user_prefs.save()
		Event.emit_signal("world_s_op")
