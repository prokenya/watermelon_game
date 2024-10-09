extends Control

@onready var sfx = %HSlider
@onready var music = %music

@export var bus_name: String
@export var bus_name2: String
var bus_index: int
var bus_index2: int
var user_prefs: UserPref

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	bus_index2 = AudioServer.get_bus_index(bus_name2)
	user_prefs = UserPref.load_or_create()
	up_audio()

func up_audio():
	_on_h_slider_value_changed(user_prefs.SFX_lv)
	if user_prefs:
		sfx.value = user_prefs.SFX_lv
		music.value = user_prefs.music

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
	user_prefs.SFX_lv = value
	user_prefs.save()


func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(
		bus_index2,
		linear_to_db(value)
	)
	user_prefs.music = value
	user_prefs.save()
