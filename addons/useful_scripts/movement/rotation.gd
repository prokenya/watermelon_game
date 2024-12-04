extends Node3D

## which axis should we rotate about
## can be mixed
@export var rotationAxis = Vector3(1,1,1)

## the speed of the rotation
@export var speed = 1.0

var originalTransform : Transform3D

# Called when the node enters the scene tree for the first time.
func _ready():
	originalTransform = transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# first, let's get the time
	# so that we can animate things
	var milliseconds = Time.get_ticks_msec()
	
	# amazing. we now know the time.
	# Only issue: milliseconds are suuuperfast.
	# My head rather thinks in seconds.
	# luckily, we can easily convert them by dividing by thousand
	# a.k.a multiplying with 0.001
	var seconds = milliseconds * 0.001
	
	var axis = rotationAxis.normalized()
	var angle = seconds * speed
	transform = originalTransform.rotated_local(axis.normalized(), angle)
