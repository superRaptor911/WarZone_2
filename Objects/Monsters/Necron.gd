extends "res://Objects/Monsters/Monster.gd"
class_name Necron

var target_lost : bool =true
var last_state : bool = false



func _ready():
	setSkin(game_states.modelResource.zombie_model.instance())
	connect("char_killed",self,"_on_necron_killed")
	if get_tree().is_network_server():
		$vision_update.start()
		$target_update.start()
	
func _on_necron_killed():
	$bloodSpot.emitting = false
	skin.queue_free()
	skin = null
	$free_timer.start()

func roam(delta : float):
	follow_path(delta)
	if at_dest:
		if position == main_destination:
			set_path(initial_position)
		else:
			set_path(main_destination)
		at_dest = false
		
func condition_roam():
	for o in char_array:
		if o.is_in_group("User"):
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(global_position, o.global_position,[self], collision_mask)
			if result:
				if result.collider.is_in_group("User"):
					target = o

func _is_target_visible() ->bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, target.global_position,[self], collision_mask)
	if result:
		if result.collider.is_in_group("User"):
			return true
		return false
	return false

func attack(delta : float):
	if not target.alive:
		_get_nearest_player()
		at_dest = true
		return
	destination = target.position
	movement_vector = (destination - position).normalized()
	if (destination - position).length() <= attack_radius:
		target.takeDamage(damage ,null,self)



func _process(delta):
	if not get_tree().is_network_server() or not alive:
		return
	if target == null:
		return
	if not nav_ready:
		set_path(target.position)
	else:
		if not target_lost:
			at_dest = true
			attack(delta)
		else:
			if at_dest:
				set_path(target.position)
			else:
				follow_path(delta)
	rpc("_sync_position",position,rotation)

remote func _sync_position(pos,rot):
	position = pos
	rotation = rot


func _on_free_timer2_timeout():
	queue_free()


func _on_vision_update_timeout():
	target_lost = not _is_target_visible()
	$vision_update.start()


func _on_target_update_timeout():
	_get_nearest_player()
	$target_update.start()
