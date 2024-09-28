extends CharacterBody3D

@export var damage = 100
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var players = []
@onready var target
var SPEED = 2.0
const JUMP_VELOCITY = 4.5
@onready var area_3d = $Area3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	find_players_in_group()

func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)

func get_closest_node(target_position: Vector3, nodes: Array) -> CharacterBody3D:
	var min_distance: float = INF
	var closest_node: CharacterBody3D = null
	for node in nodes:
		var distance = target_position.distance_to(node.position)
		if distance < min_distance:
			min_distance = distance
			closest_node = node
	return closest_node

func _physics_process(delta):
	if players.size() == 0:
		return

	target = get_closest_node(global_position, players)
	if target:
		var plTransform = target.transform.origin
		plTransform.y = transform.origin.y
		look_at(plTransform, Vector3.UP)
		var curPos = global_position
		var next_pos = navigation_agent_3d.get_next_path_position()
		var new_vel = (next_pos - curPos).normalized() * SPEED

		if curPos.distance_to(plTransform) > 500:
			SPEED = 0
		else:
			SPEED = 3
		
		velocity = velocity.move_toward(new_vel, .25)
		move_and_slide()

func op_tg_loc(target_loc):
	navigation_agent_3d.set_target_position(target_loc)

func _process(delta):
	if target:
		op_tg_loc(target.global_transform.origin)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("damage"):
		queue_free()
