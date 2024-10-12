extends Node

var ITEM_TEXTURES: Array = []
var ITEM_STACK_LIM: Array = []
var WORLD_ITEM: Array = []
var HEND_ITEM: Array = []
var default_item = ["res://scen/items/abeme.tscn","res://scen/items/inventory/abeme_inv.tscn",
"res://textures/1182467.160.webp",1]
var items:Dictionary = {}
var config = ConfigFile.new()
func _ready() -> void:
	items = update_item(items)
	items = defitems(items)
	set_data_type(items)

func defitems(data: Dictionary):
	for key in data.keys():
		for i in range(data[key].size()):
			if str(data[key][i]) == "0":
				data[key][i] = default_item[i]
	return data

func update_item(data: Dictionary) -> Dictionary:
	var err = config.load("res://resources/items.cfg")

	if err != OK:
		print_debug("Ошибка загрузки файла:", err)
		return {}
	
	var loaded_data = {}

	for key in config.get_section_keys("Items"):
		loaded_data[int(key)] = config.get_value("Items", key)
	if not data.is_empty():
		for key in data.keys():
			config.set_value("Items", str(key),data[key])
		config.save("res://resources/items.cfg")
	return loaded_data

func set_data_type(items: Dictionary):
	for i in items.keys():
		var WORLD_I = load(items[i][0])
		var HEND_I = load(items[i][1])
		
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
