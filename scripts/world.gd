extends Node3D
@export var players: Array
@onready var spawn: Node3D = $spawn
@onready var directional_light_3d = $DirectionalLight3D
@onready var spawn_parent: Node3D = $"."
@export var items:Dictionary
var user_prefs: UserPref

func _ready():
	if Event.start_world_args.has("spawn_point"):
		spawn.position = Event.start_world_args["spawn_point"]
	user_prefs = UserPref.load_or_create()
	op_world_S()
	Event.connect("world_s_op",op_world_S)
	Event.connect("global_op",op_world_S)
	Event.connect("spawn_obj",spawn_obj)
	if Event.is_multiplayer == false:
		var player = load("res://scen/character.tscn").instantiate()
		player.position = spawn.position
		add_child(player)
	await get_tree().create_timer(0.2).timeout
	await find_players_in_group()
	if Event.mpp_index >= 0 and Event.mpp_index < players.size():
		players[Event.mpp_index].position = spawn.position
	items = Event.items

func management_update():
	var scene_tree = get_tree()
	var groups = ["player", "drone"]
	
	for group in groups:
		if scene_tree.has_group(group):
			for node in scene_tree.get_nodes_in_group(group):
				Event.control_id_counter += 1
				node.control_item_id = Event.control_id_counter
				

				rpc("sync_control_id", node.name, Event.control_id_counter)

# Синхронизация ID через RPC
@rpc("call_remote")
func sync_control_id(node_name: String, control_id: int):
	var node = get_node(node_name)
	if node:
		node.control_item_id = control_id


func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()

	# Проверка на то, что группа существует и не пуста
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)
		print("Игроки найдены: ", players)
	else:
		print("Группа 'player' не найдена или пуста.")

func op_world_S():
	directional_light_3d.shadow_enabled = user_prefs.shadows
	if user_prefs.high_graphics == true:
		directional_light_3d.directional_shadow_max_distance = 20
	if user_prefs.high_graphics == false:
		directional_light_3d.directional_shadow_max_distance = 15

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
	if not data.has("inventory"):
		data["inventory"] = false
	if Event.is_multiplayer == true:
		spawn_objrpc.rpc(data)
	else:
		spawn_objs(data)

@rpc("any_peer", "call_local", "reliable")
func spawn_objrpc(data: Dictionary):
	spawn_objs(data)

func spawn_objs(data: Dictionary):
	var dropped_item_scene
	if not data["inventory"]:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][0]
	else:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][1]
	for i in range(data["amount"]):
		
		var dropped_item = dropped_item_scene.instantiate()
		
		dropped_item.position = data["obj_position"]
		dropped_item.rotation = data["obj_rotation"]
		dropped_item.scale = dropped_item.scale * data["obj_scale"]
		
		if data.has("spawn_parent"):
			data["spawn_parent"].add_child(dropped_item)
		else:
			add_child(dropped_item)
		
		if dropped_item is RigidBody3D:
			dropped_item.linear_velocity = data["impulse"]
			dropped_item.angular_velocity = data["impulse"]
		
	Event.printc(str(data["pl_id"]) + " s " + str(data["spawn_obj_id"]), Color.GREEN)
