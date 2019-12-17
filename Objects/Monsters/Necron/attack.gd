extends Node2D

export var attack_distance : float = 20
var target_position : Vector2
var object
var next_states : Array


func _getTargetPos():
	for o in object.char_array:
		if o.is_in_group("User"):
			target_position = o.position
			return
	

func exec(delta):
	#object.follow_path(delta)
	_getTargetPos()
	object.destination = target_position
	object.movement_vector = (target_position - object.position).normalized()
	
func chkNewState():
	if not condition():
		for n in next_states:
			return n;
	return self
	
func condition() -> bool:
	for o in object.char_array:
		if o.is_in_group("User"):
			var space_state = object.get_world_2d().direct_space_state
			var result = space_state.intersect_ray(object.global_position, o.global_position,[object], object.collision_mask)
			if result:
				if result.collider.is_in_group("User"):
					return true
	return false