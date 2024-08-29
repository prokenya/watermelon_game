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
		rich_text_label.push_color(Color.GREEN)
		rich_text_label.add_text("\n" + str(result))
		# Do stuff with the result

# Reload the current scene
func reload() -> void:
	get_tree().reload_current_scene()

func _on_line_edit_text_submitted(new_text: String) -> void:
	on_run_command(new_text)
	line_edit.text = ""

func clear():
	rich_text_label.text = ""

func printd(data):
	rich_text_label.push_color(Color.YELLOW)
	rich_text_label.add_text("\n" + str(data))
