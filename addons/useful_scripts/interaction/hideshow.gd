extends Node

## show or hide nodes based on .
##
## The description of the script, what it can do,
## and any further detail.
##
## @tutorial

@export var trigger_distance : float = 4.0
@export var use_area3d : bool = false
var trigger_area : Area3D = null

## if set to `true`, 
@export var one_shot : bool = false

var show_group : Node3D = null
var hide_group : Node3D = null

var is_triggered = null

func show():
	if show_group and show_group.is_inside_tree():
		remove_child(show_group)
	if hide_group and not hide_group.is_inside_tree():
		add_child(hide_group)
		
func hide():
	if show_group and not show_group.is_inside_tree():
		add_child(show_group)
	if hide_group and hide_group.is_inside_tree():
		remove_child(hide_group)

func trigger_enter(body):
	if body == $"../Player":
		hide()
func trigger_exit(body):
	if body == $"../Player":
		show()

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("show_on_trigger"):
		show_group = $show_on_trigger

	if has_node("hide_on_trigger"):
		hide_group = $hide_on_trigger
		
	if use_area3d and has_node("trigger"):
		trigger_area = $trigger
		trigger_area.body_entered.connect(trigger_enter)
		trigger_area.body_exited.connect(trigger_exit)
		show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not use_area3d:
		var d = self.global_position.distance_to($"../Player".global_position)
		if d < trigger_distance and is_triggered != true:
			is_triggered = true
			hide()
		elif d > trigger_distance and is_triggered != false and not one_shot:
			is_triggered = false
			show()
