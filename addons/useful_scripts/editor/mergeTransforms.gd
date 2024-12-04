@tool
extends EditorScript

# helper function to collect all children of a specific type in an array
func find_children_of_type(mom : Node, NeedleClass = Node, recursive : bool = true) -> Array[Node]:
	var out : Array[Node] = []
	for child : Node in mom.get_children():
		if is_instance_of(child, NeedleClass):
			out.append(child)
		if recursive:
			out.append_array(find_children_of_type(child, NeedleClass, recursive))
	return out
	
# helper function to figure out if there are children of a specific type
func has_children_of_type(mom : Node, NeedleClass = Node, recursive : bool = true) -> bool:
	for child : Node in mom.get_children():
		if is_instance_of(child, NeedleClass):
			return true
		if recursive and has_children_of_type(child, NeedleClass, recursive):
			return true
	return false

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	# make sure we are in the editor
	if Engine.is_editor_hint():
		var nodes : Array[Node] = EditorInterface.get_selection().get_selected_nodes()
		for node in nodes:
			if is_instance_of(node, Node3D) and has_children_of_type(node, Node3D, false):
				print("yesss %s" % node.name)
				var average : Vector3 = Vector3(0,0,0)
				var childs = find_children_of_type(node, Node3D, false)
				for child in childs:
					var diff = child.position
					average += diff
				average /= childs.size()
				
				for child in childs:
					child.position -= average
				node.position += average
