extends ItemList

var tscn_files: Array = ["res://scen/levels/level-1.tscn",
						"res://scen/levels/main_test_s.tscn"
						]
@onready var item_list: ItemList = $"."
var args = {"spawn_point": Vector3(0,100,0) }
var base_prefs:bool = false

func _ready():
	var levels_path: String = "user://levels"
	
	# Проверяем наличие папки levels
	var dir = DirAccess.open(levels_path)
	if dir == null:
		Event.printc("Папка 'levels' не найдена. Создаю новую.")
		var user_dir = DirAccess.open("user://")
		if user_dir:
			user_dir.make_dir(levels_path)  # Создаем папку levels
	else:
		Event.printc("Папка 'levels' уже существует.")
	
	# Получаем список всех .tscn файлов
	get_tscn_files_in_directory(levels_path)
	
	# Выводим список найденных файлов
	for file_path in tscn_files:
		Event.printc("Найдена сцена: " + file_path,Color.GREEN)
	for i in len(tscn_files):
		item_list.add_item(tscn_files[i],load("res://textures/1182467.160.webp"))
		Event.printc("добавлен уровень: " + tscn_files[i],Color.GREEN)

# Функция для поиска всех .tscn файлов в указанной директории
func get_tscn_files_in_directory(directory_path: String):
	Event.printc("поиск пользовательских уровней...")
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue
			
			var file_path = directory_path + "/" + file_name
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				# Добавляем путь к сцене в список
				tscn_files.append(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		Event.printc("Не удалось открыть директорию: " + directory_path,Color.RED)



func _on_item_activated(index: int) -> void:
	if Event.is_multiplayer == false:
		if base_prefs == true:
			args["world"] = tscn_files[index]
			Event.start_world_args = args
		else:Event.start_world_args = {}
		get_tree().change_scene_to_file(tscn_files[index])
	if Event.is_multiplayer == true:
		if base_prefs == true:
			args["world"] = tscn_files[index]
			Event.start_world_args = args
		else:Event.start_world_args = {}
		get_tree().change_scene_to_file("res://scen/gui/multi_play_core.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	Event.is_multiplayer = toggled_on


func _on_check_box_2_toggled(toggled_on: bool) -> void:
	base_prefs = toggled_on
