extends Node

var object
var next_states : Array

func exec(delta):
	object.follow_path(delta)
	if object.at_dest:
		if object.position == object.main_destination:
			object.set_path(object.initial_position)
		else:
			object.set_path(object.main_destination)
		object.at_dest = false
	
func chkNewState():
	for n in next_states:
		if n.condition():
			return n
	return self