extends Control

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/RichTextLabel
var players = []
func on_run_command(cmd: String) -> void:
	# Create an Expression instance
	var expression = Expression.new()
	var parse_error = expression.parse(cmd)
	if parse_error != OK:
		rich_text_label.push_color(Color.RED)
		rich_text_label.add_text("\n" + expression.get_error_text())
		return
	var result = expression.execute([], self)
	if result != null:
		printd(result,Color.GREEN)
		# Do stuff with the result

# Reload the current scene
func reload() -> void:
	get_tree().reload_current_scene()

func clear():
	rich_text_label.clear()

func printd(data,color:Color = Color.YELLOW):
	rich_text_label.push_color(color)
	rich_text_label.add_text("\n" + str(data))

func get_cid():
	find_players_in_group()
	printd("current_id> " + str(Event.control_id)+"\nplayer_id> " + str(Event.player_control_id) +
	"\nplayers in world:"+str(len(players))+"\n"+str(players))

func help() -> void:
	printd("Available Commands:")
	printd("reload() - Reloads the current scene.")
	printd("clear() - Clears the text in the RichTextLabel.")
	printd("printd(data, color: Color = Color.YELLOW) - Prints data to the RichTextLabel with an optional color.")
	printd("get_cid() - Displays current control ID, player ID, and the number of players in the world.")
	printd("get_log() - Reads and prints lines from the log file if it exists.")
	printd("tp(x: int = 0, y: int = 0, z: int = 0, pl_id: int = Event.mpp_index) - Teleports a player to specified coordinates.")
	printd("spawn(id: int, x: int = 0, y: int = 10, z: int = 0, amount: int = 1) - Spawns an object with a specified ID and amount at given coordinates.")
	printd("time(uscale: float) - Changes the time scale in the game. Default is 1.0 for normal speed.")


func get_log():
	var log_file_path = "user://logs/godot.log"
	# Проверяем, существует ли файл
	if FileAccess.file_exists(log_file_path):
		var file = FileAccess.open(log_file_path, FileAccess.READ)
		
		if file:
			printd("Чтение данных из файла лога:")
			
			# Читаем весь файл построчно
			while not file.eof_reached():
				var line = file.get_line()
				printd(line)  # Выводим считанную строку
			
			file.close()  # Закрываем файл
		else:
			printd("Не удалось открыть файл.",Color.RED)
	else:
		printd("Файл не существует.",Color.RED)

func time(uscale:float):
	Engine.time_scale = uscale

func tp(x = 1, y = 1, z = 1, pl_id: int = Event.mpp_index):
	# Обновляем позицию игрока
	find_players_in_group()
	players[pl_id].position = Vector3(float(x), float(y), float(z))


func spawn(id:int,x = 0,y = 10,z = 0,amount:int = 1):
	var data = {
		"spawn_obj_id": id,
		"obj_position": Vector3(x,y,z),
		"obj_rotation": Vector3.UP,
		"obj_scale": Vector3(1, 1, 1),
		"amount": amount,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
	Event.emit_signal("spawn_obj",data)

func _ready() -> void:
	Event.connect("run_comand",on_run_command)
	Event.connect("printd",printd)

func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()

	# Проверка на то, что группа существует и не пуста
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)

func _on_line_edit_text_submitted(new_text: String) -> void:
	on_run_command(new_text)
	line_edit.text = ""
