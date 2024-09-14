extends ItemList

var tscn_files: Array = []
@onready var item_list: ItemList = $"."
var args = { "spawn_point": Vector3(0,100,0) }
func _ready():
	# Укажи директорию для поиска файлов
	var directory_path: String = "res://scen/levels"
	get_tscn_files_in_directory(directory_path)
	print(tscn_files)
	for i in range(len(tscn_files)):
		item_list.add_item(tscn_files[i].replace("res://scen/levels/",""),load("res://textures/1182467.160.webp"))

# Функция для поиска всех .tscn файлов в указанной директории и её поддиректориях
func get_tscn_files_in_directory(directory_path: String):
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()  # Начинаем перечисление файлов
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue

			var file_path = directory_path + "/" + file_name
			if dir.current_is_dir():  # Если это директория, продолжаем искать внутри неё
				get_tscn_files_in_directory(file_path)
			elif file_name.ends_with(".tscn"):  # Если это файл .tscn, добавляем его в список
				tscn_files.append(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()  # Завершаем перечисление файлов
	else:
		print("Не удалось открыть директорию: " + directory_path)


func _on_item_activated(index: int) -> void:
	if Event.is_multiplayer == false:
		Event.start_world_args = {"world":tscn_files[index]}
		get_tree().change_scene_to_file(tscn_files[index])
	if Event.is_multiplayer == true:
		Event.start_world_args = {"world":tscn_files[index]}
		get_tree().change_scene_to_file("res://scen/gui/multi_play_core.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	Event.is_multiplayer = toggled_on
