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
	if Event.is_multiplayer == false:
		var player = load("res://scen/character.tscn").instantiate()
		player.position = spawn.position
		add_child(player)
	await get_tree().create_timer(0.2).timeout
	await find_players_in_group()
	if Event.mpp_index >= 0 and Event.mpp_index < players.size():
		players[Event.mpp_index].position = spawn.position
	items = Event.items

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
