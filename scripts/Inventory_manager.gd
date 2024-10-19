extends Node

var ITEM_TEXTURES: Array = []
var ITEM_STACK_LIM: Array = []
var WORLD_ITEM: Array = []
var HEND_ITEM: Array = []
var default_item = ["res://scen/items/abeme.tscn","res://scen/items/inventory/abeme_inv.tscn",
"res://textures/1182467.160.webp",1]
var items:Dictionary = {
	-1:["res://scen/items/enemy.tscn", 0, 0, 1],
	0:["res://scen/items/drone.tscn", "res://scen/items/inventory/drone_inv.tscn", "res://textures/icons/drone.png", 3],
	1:["res://scen/items/ak_drop.tscn", "res://scen/items/inventory/watermelon_gun.tscn", "res://textures/icons/ak_w.png", 1],
	2:["res://scen/items/watermelon.tscn", "res://scen/items/inventory/watermelon_inv.tscn", "res://textures/icons/watermelon.png", 10],
	3:["res://scen/items/drone_exp.tscn", 0, 0, 3],
	4:["res://scen/items/bullet.tscn", 0, 0, 1],
	5:["res://scen/items/abeme.tscn", "res://scen/items/inventory/abeme_inv.tscn", "res://textures/model_0.png", 5]
	}
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
	var config = ConfigFile.new()
	var config_path = "user://items.cfg"

	# Сохраняем данные, если передан непустой словарь
	if not data.is_empty():
		for key in data.keys():
			config.set_value("Items", str(key), data[key])
		var save_err = config.save(config_path)
		if save_err != OK:
			print_debug("Ошибка сохранения файла:", save_err)
			return {}

	# Загружаем данные из файла
	var load_err = config.load(config_path)
	if load_err != OK:
		print_debug("Ошибка загрузки файла:", load_err)
		return {}
	
	# Проверка, существует ли секция "Items"
	if not config.has_section("Items"):
		print_debug("Секция 'Items' не найдена в файле конфигурации.")
		return {}

	# Читаем данные из секции "Items"
	var loaded_data = {}
	for key in config.get_section_keys("Items"):
		loaded_data[int(key)] = config.get_value("Items", key)
	
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
