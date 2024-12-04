extends Node3D

## the object that triggers and is being teleported.
## Usually this is the player.
@export var player : Node3D

## The distance when the 
@export var triggerDistance = 2.0

## where to teleport to
@export var target : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position.distance_to(player.global_position) < triggerDistance:
		player.global_position = target.global_position
		player.global_transform = target.global_transform
