extends "res://Objects/Character.gd"

var _near_bodies = Array()
var visible_bodies = Array()

func _ready():
	if get_tree().is_network_server():
		$VisionTimer.wait_time = $VisionTimer.wait_time * (1 + rand_range(-0.5,0.5))
		$VisionTimer.start()

func _on_vision_body_entered(body):
	if body.is_in_group("Actor"):
		_near_bodies.append(body)



func _on_vision_body_exited(body):
	if body.is_in_group("Actor"):
		_near_bodies.erase(body)

func _on_VisionTimer_timeout():
	visible_bodies.clear()
	for i in _near_bodies:
		if i and i.alive:
			#raycast chks
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(position, i.position,
													[self], collision_mask)
			if result:
				if result.collider.name == i.name:
					visible_bodies.append(i)
					if game_server.serverInfo.game_mode == "FFA" or i.team.team_id != team.team_id:
						$Brain.visible_enemies.append(i)
						print("enemy found")
					else:
						$Brain.visible_friends.append(i)
