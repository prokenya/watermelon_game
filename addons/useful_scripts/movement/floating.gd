extends Node3D

## The minimum position
@export var movementRadius = Vector3(1,1,1)

## This is the offset in time. Just try it.
## For example, if x has an offset of 0 and y and offset of 1
## you will see a circular movement, but if both are the same, it is diagonal.
@export var timeOffset = Vector3(0,0,0)

## How fast should each axis move
@export var speed = Vector3(1,1,1)

## let's store the original position
## so our movement will be relative to this
var originalPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	# We get the originalPosition, so that where ever we move later,
	# we still know where we're coming from.
	originalPosition = position

# _physics_process is very similar to _process
# It is called in an infinite loop over and over again.
# thhough _process might run faster or slower depending on the framerate.
# _physics_process will try to run always at the same speed
# => when in doubt, just use _process. in 99.99% of the cases it will be just fine.
# The reason why I used _physics_process anyways is, that you might want to attach
# this script to an object you want to walk on. then physics are involved and it may jitter
# in some cases a tiny bit when you use _process
func _physics_process(_delta):
	# first, let's get the time
	# so that we can animate things
	var milliseconds = Time.get_ticks_msec()
	
	# fantastic. we now know the time.
	# Only issue: milliseconds are suuuperfast.
	# My head rather thinks in seconds.
	# luckily, we can easily convert them by dividing by thousand
	# a.k.a multiplying with 0.001
	var seconds = milliseconds * 0.001
	
	# And now.. move!
	# This code is the most complicated part of this
	# but essentially it is based on the sine function
	# to get smooth back and forth movement.
	# More about the sine function:
	# https://en.wikipedia.org/wiki/Sine_and_cosine#Differential_equation_definition
	# https://yt.artemislena.eu/watch?v=a_zReGTxdlQ
	# https://yt.artemislena.eu/watch?v=Q55T6LeTvsA
	# https://yt.artemislena.eu/watch?v=fPPDVTVRnfY
	# Anyways, here we go:
	var movement_x = sin(seconds * speed.x + timeOffset.x * PI / 2) * movementRadius.x
	var movement_y = sin(seconds * speed.y + timeOffset.y * PI / 2) * movementRadius.y
	var movement_z = sin(seconds * speed.z + timeOffset.z * PI / 2) * movementRadius.z
	
	# Alright. Let's apply this movement.
	# If we add it to the originalPosition, it will be relative to it.
	# Practically this means that even though we set the movement with code
	# we can still move things around in the editor
	position.x = movement_x + originalPosition.x
	position.y = movement_y + originalPosition.y
	position.z = movement_z + originalPosition.z
