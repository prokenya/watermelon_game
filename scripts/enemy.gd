extends CharacterBody3D

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var target = $"../player"
var SPEED = 2.0
const JUMP_VELOCITY = 4.5
@onready var area_3d = $Area3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	var plTransform = target.transform.origin
	plTransform.y = transform.origin.y
	look_at(plTransform,Vector3.UP)
	self.rotate_object_local(Vector3.UP,PI)
	var curPos = global_position
	var next_pos = navigation_agent_3d.get_next_path_position()
	
	var new_vel = (next_pos - curPos).normalized()* SPEED
	if curPos.distance_to(plTransform) > 20:
		SPEED = 0
	else:
		SPEED = 3
	velocity = velocity.move_toward(new_vel,.25)
	move_and_slide()
func op_tg_loc(target_loc):
	navigation_agent_3d.set_target_position(target_loc)

func _process(delta):
	op_tg_loc(target.global_transform.origin)


func _on_hurt_area_entered(area):
	if area.editor_description == "hurt":
		queue_free()
	if area.editor_description == "hurt1m":
		queue_free()
