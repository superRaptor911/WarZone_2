extends "res://Objects/Character.gd"

var pname : String = "xxx"
var id = 0
var _near_bodies = Array()
var visible_bodies = Array()
var primary_gun = null
var sec_gun = null
var selected_gun = null

var bot_data : Dictionary = {
	bot_g1 = "",
	bot_g2 = ""
}


func _ready():
	switchGun()
	if get_tree().is_network_server():
		$VisionTimer.wait_time = $VisionTimer.wait_time * (1.0 + rand_range(-0.5,0.5))
		$VisionTimer.start()
		connect("char_killed",self,"_on_bot_killed")
	else:
		$Brain.queue_free()

func load_guns(nam : String , nam2 : String):
	var g = game_states.weaponResource[nam].instance()
	var g2 = game_states.weaponResource[nam2].instance()
	if primary_gun:
		primary_gun.queue_free()
	primary_gun = g
	if sec_gun:
		sec_gun.queue_free()
	sec_gun = g2
	
	if not skin:
		selected_gun = primary_gun
		return
	skin.get_node("body/r_shoulder/arm/joint/hand/fist").remove_child(selected_gun)
	selected_gun = primary_gun
	skin.get_node("body/r_shoulder/arm/joint/hand/fist").add_child(selected_gun)
	selected_gun.connect("gun_fired",skin,"_on_gun_fired")
	selected_gun.connect("reloading_gun",skin,"_on_gun_reload")
	selected_gun.gun_user = self


remotesync func switchGun():
	skin.switchGun(selected_gun.gun_type)
	if selected_gun == primary_gun:
		if sec_gun != null:
			skin.get_node("body/r_shoulder/arm/joint/hand/fist").remove_child(selected_gun)
			selected_gun = sec_gun
			skin.get_node("body/r_shoulder/arm/joint/hand/fist").add_child(selected_gun)
	else:
		skin.get_node("body/r_shoulder/arm/joint/hand/fist").remove_child(selected_gun)
		selected_gun = primary_gun
		skin.get_node("body/r_shoulder/arm/joint/hand/fist").add_child(selected_gun)
	
	selected_gun.connect("gun_fired",skin,"_on_gun_fired")
	selected_gun.connect("reloading_gun",skin,"_on_gun_reload")
	selected_gun.gun_user = self
	selected_gun.position = Vector2(0,0)

func switchToPrimaryGun():
	if selected_gun != primary_gun:
		rpc("switchGun")

func respawnBot():
	var spawn_points
	for sp in get_tree().get_nodes_in_group("spawn_points"):
		spawn_points = sp.get_children()
	var id = randi() % spawn_points.size()
	rpc("sync_respawn",spawn_points[id].position)

remotesync func sync_respawn(pos):
	show()
	$dtween.stop(skin)
	$dtween.interpolate_property(skin,"modulate",Color8(50,50,200,255),Color8(255,255,255,255),4,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$dtween.start()
	alive = true
	skin.set_deferred("disabled",false)
	HP = 100
	AP = 100
	position = pos
	$movmtCPP._teleportCharacter(pos)
	load_guns(bot_data.bot_g1, bot_data.bot_g2)
	switchGun()
	skin.revive()

func _on_free_timer_timeout():
	respawnBot()

func _on_bot_killed():
	$free_timer.start()

########################bot vision####################

func _on_vision_body_entered(body):
	if body.is_in_group("Actor"):
		_near_bodies.append(body)

func _on_vision_body_exited(body):
	if body.is_in_group("Actor"):
		_near_bodies.erase(body)

func _on_VisionTimer_timeout():
	visible_bodies.clear()
	$Brain.visible_enemies.clear()
	$Brain.visible_friends.clear()
	
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
					else:
						$Brain.visible_friends.append(i)
