extends Node3D

@onready var player = $player

@onready var directional_light_3d = $DirectionalLight3D
@onready var enemy = preload("res://scen/enemy.tscn")
var user_prefs: UserPref

func _ready():
	user_prefs = UserPref.load_or_create()
	op_world_S()
	Event.connect("world_s_op",op_world_S)
	Event.connect("spawn_enemy",spawn_enemy)
	Event.connect("global_op",op_world_S)
	Event.connect("control", ds_control)
	if Event.is_multiplayer == false:
		var player = preload("res://scen/character.tscn").instantiate()
		player.position = directional_light_3d.position
		add_child(player)

func ds_control(id):
	if id != 0:
		pass
func op_world_S():
	directional_light_3d.shadow_enabled = user_prefs.shadows
	if user_prefs.high_graphics == true:
		directional_light_3d.directional_shadow_max_distance = 20
	if user_prefs.high_graphics == false:
		directional_light_3d.directional_shadow_max_distance = 15

func spawn_enemy():
	var number_of_targets = 3
	for i in range(number_of_targets):
		spawn_target()

func spawn_target():
	var enemysp = enemy.instantiate()
	add_child(enemysp)
	enemysp.position = Vector3(
		randf_range(-20, 20), 
		randf_range(10, 10), 
		randf_range(-20, 20)     
	)

func randf_range(min_val, max_val):
	return randf() * (max_val - min_val) + min_val
