extends Node3D
@export var players: Array
@onready var spawn: Node3D = $spawn
@onready var directional_light_3d = $DirectionalLight3D
@onready var enemy = preload("res://scen/enemy.tscn")
var user_prefs: UserPref

func _ready():
	if Event.start_world_args.has("spawn_point"):
		spawn.position = Event.start_world_args["spawn_point"]
	user_prefs = UserPref.load_or_create()
	op_world_S()
	Event.connect("world_s_op",op_world_S)
	Event.connect("spawn_enemy",spawn_enemy)
	Event.connect("global_op",op_world_S)
	Event.connect("control", ds_control)
	if Event.is_multiplayer == false:
		var player = load("res://scen/character.tscn").instantiate()
		player.position = spawn.position
		add_child(player)
	call_deferred("find_players_in_group")
	await get_tree().create_timer(0.2).timeout
	players[Event.mpp_index].position = spawn.position
	

func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()

	# Проверка на то, что группа существует и не пуста
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)

	# Выводим найденные узлы
	print("Players in group: ", players)

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
