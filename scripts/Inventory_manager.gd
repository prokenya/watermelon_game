extends Node

var ITEM_TEXTURES: Array = []
var ITEM_STACK_LIM: Array = []
var WORLD_ITEM: Array = []
var HEND_ITEM: Array = []
var default_item = ["res://scen/items/abeme.tscn","res://scen/items/inventory/abeme_inv.tscn",
"res://textures/1182467.160.webp",1,null,"item"]
var new_items:Dictionary = {}
#world_item,inventory_item,texture,st_lim,subnode,name
var item_ids_to_erase:Array = []
var item_data = Data.load_or_create()
@export var items:Dictionary

func _ready() -> void:
	items = item_data.items_paths.duplicate(true)
	#push_items()
	#erase_ids()
	items = defitems(items)
	load_data_types(items)
	#print(item_data.items_paths)

func erase_ids():
	for id in item_ids_to_erase:
		items.erase(id)
	item_data.items_paths = items
	item_data.save()

func push_items():
	items.merge(new_items,true)
	item_data.items_paths = items
	item_data.save()
	

func defitems(data: Dictionary):
	for key in data.keys():
		for i in range(data[key].size()):
			if str(data[key][i]) == "0":
				data[key][i] = default_item[i]
	return data


func load_data_types(items: Dictionary):
	for i in items.keys():
		var WORLD_I = load(items[i][0])
		var HEND_I = load(items[i][1])
		if items[i][4] != null:
			var sub_node = load(items[i][4])
			items[i][4] = sub_node
		if WORLD_I:
			items[i][0] = WORLD_I  # объект мира
		if HEND_I:
			items[i][1] = HEND_I  # объект в руках
		if i >= 0:
			var texture_path = items[i][2]
			var texture = load(texture_path)
			var stack = items[i][3]
			if texture:
				items[i][2] = texture  # текстура
				ITEM_TEXTURES.append(texture)
			if stack:
				items[i][3] = stack
				ITEM_STACK_LIM.append(stack)
