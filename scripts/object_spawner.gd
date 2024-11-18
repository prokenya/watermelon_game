extends Node3D

@onready var objects_spawner: MultiplayerSpawner
func _ready() -> void:
	if inworld == true and Event.is_multiplayer == true:
		queue_free()
	if Event.is_multiplayer == true and inworld == false:
		objects_spawner = $OBJECTS_SPAWNER
		print_debug(objects_spawner)
		var items = data.new().items
		for key in items.keys():
			objects_spawner.add_spawnable_scene(items[key][0])
	Event.connect("spawn_obj",spawn_obj)

@export var inworld:bool=false


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
		if multiplayer.is_server():
			spawn_objs.call_deferred(data)
		else:
			spawn_objrpc.rpc(data)
			
	else:
		spawn_objs.call_deferred(data)

@rpc("reliable","call_remote","any_peer")
func spawn_objrpc(data: Dictionary):
	spawn_objs.call_deferred(data)

func spawn_objs(data: Dictionary):
	var dropped_item_scene
	var dropped_item_sub_scenei
	var dropped_item_sub_scene = InventoryManager.items[data["spawn_obj_id"]][4]
	
	if not data["inventory"]:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][0]
	else:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][1]
	for i in range(data["amount"]):
		if dropped_item_sub_scene != null:
			dropped_item_sub_scenei = dropped_item_sub_scene.instantiate()
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.position = data["obj_position"]
		dropped_item.rotation = data["obj_rotation"]
		dropped_item.scale = dropped_item.scale * data["obj_scale"]
		
		if data.has("spawn_parent"):
			data["spawn_parent"].add_child(dropped_item)
		else:
			add_child(dropped_item,true)
			if dropped_item_sub_scene != null:
				dropped_item.item_id = data["spawn_obj_id"]
				dropped_item.add_child(dropped_item_sub_scenei,true)
		if dropped_item is RigidBody3D:
			dropped_item.linear_velocity = data["impulse"]
			dropped_item.angular_velocity = data["impulse"]
		
	Event.printc(str(data["pl_id"]) + " s " + str(data["spawn_obj_id"]), Color.GREEN)
