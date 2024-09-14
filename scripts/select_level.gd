extends ItemList

var tscn_files: Array = []
@onready var item_list: ItemList = $"."
var args = {"spawn_point": Vector3(0,100,0) }

func _ready():
	var levels_path: String = "res://scen/levels"
	var user_levels_path: String = "user://levels"
	
	# Создаем папку в user://, если ее нет
	var dir = DirAccess.open(user_levels_path)
	if dir == null:
		dir = DirAccess.open("user://")  # Открываем базовую директорию user://
		if dir:
			dir.make_dir(user_levels_path)  # Создаем директорию levels в user://
	
	# Копируем уровни из res:// в user://
	copy_levels_to_user(levels_path, user_levels_path)
	call_deferred("get_tscn_files_in_user_levels")

func copy_levels_to_user(src_dir: String, dest_dir: String):
	var dir = DirAccess.open(src_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue

			var src_file_path = src_dir + "/" + file_name
			var dest_file_path = dest_dir + "/" + file_name
			
			if dir.current_is_dir():
				Event.printc("создание папки user://")
				# Создаем папку в user:// и копируем содержимое
				var sub_dir = DirAccess.open(dest_file_path)
				if sub_dir == null:
					var dest_dir_access = DirAccess.open(dest_dir)
					if dest_dir_access:
						dest_dir_access.make_dir(dest_file_path)
				copy_levels_to_user(src_file_path, dest_file_path)
			elif file_name.ends_with(".tscn"):
				# Копируем файл в user://
				Event.printc("копирование...")
				var file = FileAccess.open(src_file_path, FileAccess.READ)
				if file:
					var data = file.get_buffer(file.get_length())
					file.close()
					var dest_file = FileAccess.open(dest_file_path, FileAccess.WRITE)
					if dest_file:
						dest_file.store_buffer(data)
						dest_file.close()
						Event.printc("Сцена скопирована: " + dest_file_path,Color.GREEN)
			file_name = dir.get_next()
		dir.list_dir_end()

func get_tscn_files_in_user_levels():
	tscn_files = []
	var levels_path: String = "user://levels"
	
	var dir = DirAccess.open(levels_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue

			var file_path = levels_path + "/" + file_name
			if dir.current_is_dir():
				# Если найдена поддиректория, можем пропустить или обработать рекурсивно
				# Для простоты пропустим
				file_name = dir.get_next()
				continue
			elif file_name.ends_with(".tscn"):
				# Добавляем путь к сцене в список
				tscn_files.append(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Не удалось открыть директорию: " + levels_path)
	Event.printc("load levels: " + str(tscn_files),Color.GREEN)
	for i in len(tscn_files):
		item_list.add_item(tscn_files[i],load("res://textures/1182467.160.webp"))


func _on_item_activated(index: int) -> void:
	if Event.is_multiplayer == false:
		Event.start_world_args = {"world":tscn_files[index]}
		get_tree().change_scene_to_file(tscn_files[index])
	if Event.is_multiplayer == true:
		Event.start_world_args = {"world":tscn_files[index]}
		get_tree().change_scene_to_file("res://scen/gui/multi_play_core.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	Event.is_multiplayer = toggled_on
