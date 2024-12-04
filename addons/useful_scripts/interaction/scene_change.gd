extends Node3D

@export var player : Node3D
@export var triggerDistance = 2
@export_file var otherScene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(player)
	if global_position.distance_to(player.global_position) < triggerDistance:
		get_tree().change_scene_to_file(otherScene)
