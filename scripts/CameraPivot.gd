extends Node3D

var sensitivity = 0.3
var tracked_touch_index = -1  # Track the index of the touch controlling the camera
var touch_start_position
var current_rotation = Vector2()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if tracked_touch_index == -1:  # If no touch is being tracked, start tracking this one
				tracked_touch_index = event.index
				touch_start_position = event.position
		elif event.index == tracked_touch_index:  # If the released touch was the tracked one, stop tracking
			tracked_touch_index = -1

	if event is InputEventScreenDrag:
		if event.index == tracked_touch_index:  # Only process drag events for the tracked touch
			var delta = event.position - touch_start_position
			delta *= -1  # Invert the delta values
			rotate_camera(delta)
			touch_start_position = event.position

	# Check if joystick input is available (unchanged)
	if event is InputEventJoypadMotion:
		rotate_camera(Vector2(event.axis_value(0), event.axis_value(1)) * sensitivity)

func rotate_camera(delta):
	current_rotation += delta * sensitivity
	current_rotation.y = clamp(current_rotation.y, -90, 90)
	rotation_degrees.y = current_rotation.x
	rotation_degrees.x = current_rotation.y
