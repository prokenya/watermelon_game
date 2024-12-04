extends Node3D

## the target to look at
@export var player : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform = global_transform.looking_at(player.global_position)
