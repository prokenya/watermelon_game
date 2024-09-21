extends Control

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/RichTextLabel

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

func _on_line_edit_text_submitted(new_text: String) -> void:
	on_run_command(new_text)
	line_edit.text = ""

func clear():
	rich_text_label.text = ""

func printd(data,color:Color = Color.YELLOW):
	rich_text_label.push_color(color)
	rich_text_label.add_text("\n" + str(data))

func get_cid():
	printd("current_id> " + str(Event.control_id)+"\nplayer_id> " + str(Event.player_control_id))

func help():
	var script = self.get_script()
	var method_list = script.get_method_list()
	for method in method_list:
		printd(method.name)

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

func _ready() -> void:
	Event.connect("run_comand",on_run_command)
	Event.connect("printd",printd)
