extends Control

@export var mpc: MultiPlayCore
@export var host_btn: Button
@export var join_btn: Button
@export var address_bar: LineEdit

@export var button_layout: Control
@export var connecting_layout: Control
@export var connect_fail_layout: Control
@export var connect_fail_label: Label
@onready var namee: LineEdit = $VBoxContainer/Layout/Buttons/NAME

@onready var menub: CanvasLayer = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	# Register Button Press Signals
	join_btn.pressed.connect(join_game)
	host_btn.pressed.connect(host_game)
	
	# Hide UI if client were connected
	mpc.connected_to_server.connect(_on_connected_to_server)
	mpc.connection_error.connect(_on_connection_error)

# When host game requested
func host_game():
	menub.queue_free()
	Event.is_multiplayer = true
	mpc.start_online_host(true,{"name":namee.text})
	open_connecting_ui()
# When join game requested
func join_game():
	menub.queue_free()
	Event.is_multiplayer = true
	# Pass URL from address bar to MPC
	var url = address_bar.text
	mpc.start_online_join(url,{"name":namee.text})
	open_connecting_ui()

# Open Connecting UI Layout
func open_connecting_ui():
	button_layout.visible = false
	connecting_layout.visible = true
	connect_fail_layout.visible = false

# Close UI when connected to server
func _on_connected_to_server(_plr):
	visible = false

func _on_connection_error(reason: int):
	# Get value string of reason enum
	var reason_codename = MultiPlayCore.ConnectionError.keys()[reason]
	
	# Reset layout to connect buttons
	button_layout.visible = true
	connecting_layout.visible = false
	
	# Show reason
	connect_fail_label.text = "Reason: " + reason_codename
	connect_fail_layout.visible = true


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scen/gui/menu.tscn")
