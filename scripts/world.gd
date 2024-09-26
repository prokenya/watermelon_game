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
	Event.connect("spawn_obj",spawn_obj)
	if Event.is_multiplayer == false:
		var player = load("res://scen/character.tscn").instantiate()
		player.position = spawn.position
		add_child(player)
	call_deferred("find_players_in_group")
	await get_tree().create_timer(0.5).timeout
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

func spawn_obj(data: Dictionary):
	if not data.has("spawn_obj_id"):
		data["spawn_obj_id"] = 0
	if not data.has("obj_position"):
		data["obj_position"] = Vector3(0, 0, 0)
	if not data.has("obj_rotation"):
		data["obj_rotation"] = Vector3(0, 0, 0)
	if not data.has("obj_scale"):
		data["obj_scale"] = Vector3(1, 1, 1)
	if not data.has("amount"):
		data["amount"] = 1
	if not data.has("impulse"):
		data["impulse"] = Vector3(0, 0, 0)
	if not data.has("pl_id"):
		data["pl_id"] = 255
	if Event.is_multiplayer == true:
		spawn_objrpc.rpc(data)
	else:
		spawn_objs(data)

@rpc("any_peer", "call_local", "reliable")
func spawn_objrpc(data: Dictionary):
	spawn_objs(data)

func spawn_objs(data: Dictionary):
	var dropped_item_scene
	match data["spawn_obj_id"]:
		0: dropped_item_scene = preload("res://scen/drop/drone.tscn")
		1: dropped_item_scene = preload("res://scen/drop/ak_drop.tscn")
		2: dropped_item_scene = preload("res://scen/drop/watermelon.tscn")
		3: dropped_item_scene = preload("res://scen/drop/drone_exp.tscn")
		4: dropped_item_scene = preload("res://scen/drop/bullet.tscn")
		
	for i in range(data["amount"]):
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.position = data["obj_position"]
		dropped_item.rotation = data["obj_rotation"]
		# dropped_item.scale = dropped_item.scale * Vector3(1,1,1)
		add_child(dropped_item)
		# dropped_item.linear_velocity = data["impulse"] * 3
		# dropped_item.angular_velocity = data["impulse"] * 3
		
	Event.printc(str(data["pl_id"]) + " s " + str(data["spawn_obj_id"]), Color.GREEN)
