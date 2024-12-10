extends Resource 
class_name Data

@export var items_paths:Dictionary #= {-1:["res://scen/items/enemy.tscn", 0, 0, 1, 0,"enemy"],
	#0:["res://scen/items/drone.tscn", "res://scen/items/inventory/drone_inv.tscn", "res://textures/icons/drone.png", 3, 0,"drone"],
	#1:["res://scen/items/ak_drop.tscn", "res://scen/items/inventory/watermelon_gun.tscn", "res://textures/icons/ak_w.png", 1, 0,"ak_wg"],
	#2:["res://scen/items/watermelon.tscn", "res://scen/items/inventory/watermelon_inv.tscn", "res://textures/icons/watermelon.png", 10, 0,"watermelon"],
	#3:["res://scen/items/drone.tscn", 0, 0, 3, "res://scen/items/sub_nodes/explosive_module.tscn","explosive_drone"],
	#4:["res://scen/items/bullet.tscn", 0, 0, 1, 0,"bullet"],
	#5:["res://scen/items/abeme.tscn", "res://scen/items/inventory/abeme_inv.tscn", "res://textures/model_0.png", 5, 0,"abeme"],
	#6:["res://scen/vfx/vfx_expp1.tscn", 0, 0, 0, 0,"explosion_effect"]}

#id:[world_item,inventory_item,texture,st_lim,subnode,name]

func save() -> void:
	ResourceSaver.save(self, "res://resources/gamedata.tres")

static  func load_or_create() -> Data:
	var res: Data = load("res://resources/gamedata.tres") as Data
	if !res:
		res = Data.new()
	return res
