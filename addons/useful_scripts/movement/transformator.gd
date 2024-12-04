extends Node3D
class_name Transformator
## Add animated rotation and/or translation to a node.
## Translation is a fancy word for positional movement.

enum TransformType {
	## continuously increase
	CONTINUOUS,
	## swing back and forth between minimum and maximum
	SWING
}
@export_group("rotation", "rotation_")
## Toggle if should this node rotate or not
@export var rotation_enabled = false
@export_subgroup("rotation type", "rotation_type_")
## The rotation can either be continuous or swing back and forth.
@export var rotation_type_type : TransformType = TransformType.SWING
## The minimum value to swing from.
## Does not do anything if you selected continuous rotation.
@export var rotation_type_swing_min_degree = 0.0
## The maximum value to swing towards
## Does not do anything if you selected continuous rotation.
@export var rotation_type_swing_max_degree = 360.0
@export_subgroup("rotation timing offset", "rotation_timing_")
## Sometimes we want objects to rotate in the same way but at different times.
## Here you can set the offset of this node to delay the rotation.
@export var rotation_timing_manual_time_offset = 0.0
## It can be cumbersome to set a manual offset for every node, so here you can use the position of the node to calculate an automatic offset.
## Now you can move a node around and it will have an individual offset.
@export var rotation_timing_positional_time_offset = 0.0
## There are three spatial dimensions. X, Y and Z. You can define here which axis this node should rotate around. You can also combine multiple axes, then their values will be taken in relation to each other. e.g. x = 2, y = 1, z = 0 leads to twice as much rotation around the x-axis than the y-axis and no rotation around the z-axis. This is the same as x = 1, y = 0.5, z = 0
@export var rotation_axis = Vector3(0,1,0)
## Well, you can change the speed of the rotation here :-)
@export var rotation_speed = 1.0

@export_group("translation", "translation_")
## Toggle if this node should translate or not. Remember, translation is a fancy word for positional movement.
@export var translation_enabled = false
@export_subgroup("translation type", "translation_type_")
## The movement can either be continuous or swing back and forth.
@export var translation_type_type : TransformType = TransformType.SWING
## The minimum value to swing from.
## Does not do anything if you selected continuous translation.
@export var translation_type_swing_min = -1.0
## The maximum value to swing to.
## Does not do anything if you selected continuous translation.
@export var translation_type_swing_max = 1.0
@export_subgroup("translation timing offset", "translation_timing_")
## Sometimes we want objects to move in the same way but at different times.
## Here you can set the offset of this node to delay the translation.
@export var translation_timing_manual_time_offset = Vector3(0.0, 0.0, 0.0)
## It can be cumbersome to set a manual offset for every node, so here you can use the position of the node to calculate an automatic offset.
## Now you can move a node around and it will have an individual offset.
@export var translation_timing_positional_time_offset = Vector3(0.0, 0.0, 0.0)
## There are three spatial dimensions. X, Y and Z. You can define here on which axis the node should move. You can also combine multiple axes, then their values will be taken in relation to each other. e.g. x = 2, y = 1, z = 0 leads to twice as much movement on the x-axis than the y-axis and no movement on the z-axis. This is the same as x = 1, y = 0.5, z = 0
@export var translation_axis = Vector3(1,1,1)
## Well, here you can change the speed of the movement :-)
@export var translation_speed = 1.0

# The initial transform. We store it on startup.
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
	
	# phew, now it gets intricated.
	# This script may not be the best to learn coding from.
	# There is a lot happening to make it more convenient to _use_, not to _work with_.
	if rotation_enabled:
		var positional_time_offset = rotation_timing_positional_time_offset * global_position.length()
		var time_offset = rotation_timing_manual_time_offset + positional_time_offset
		if rotation_type_type == TransformType.CONTINUOUS:
			var axis = rotation_axis.normalized()
			var angle = seconds * rotation_speed + time_offset
			transform = originalTransform.rotated_local(axis, angle)
		if rotation_type_type == TransformType.SWING:
			var axis = rotation_axis.normalized()
			var angle = deg_to_rad(remap(
							sin(seconds * rotation_speed + time_offset),
							-1,
							1,
							rotation_type_swing_min_degree,
							rotation_type_swing_max_degree
						))
			
			transform = originalTransform.rotated_local(axis, angle)
	
	if translation_enabled:
		var positional_time_offset = translation_timing_positional_time_offset * global_position.length()
		var time_offset = translation_timing_manual_time_offset + positional_time_offset
		
		if translation_type_type == TransformType.CONTINUOUS:
			position = originalTransform.origin + ((translation_axis * seconds * translation_speed) + time_offset)
			
		if translation_type_type == TransformType.SWING:
			time_offset = time_offset * PI * 2
			var swing_x = remap(sin(seconds * translation_speed + time_offset.x),
							-1,
							1,
							translation_type_swing_min,
							translation_type_swing_max)
			var swing_y = remap(sin(seconds * translation_speed + time_offset.y),
							-1,
							1,
							translation_type_swing_min,
							translation_type_swing_max)
			var swing_z = remap(sin(seconds * translation_speed + time_offset.z),
							-1,
							1,
							translation_type_swing_min,
							translation_type_swing_max)
			position = originalTransform.origin + Vector3(swing_x, swing_y, swing_z) * translation_axis.normalized()
