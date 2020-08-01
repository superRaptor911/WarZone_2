extends "res://Objects/Character.gd"

var target_id = ""

var path_to_dest = PoolVector2Array()
var cur_path_id = 0
var target_visible = false
var nav : Navigation2D


var free_timer


func _ready():
	var teams = get_tree().get_nodes_in_group("Team")
	for i in teams:
		if i.team_id == 0:
			i.addPlayer(self)
	# This signal is re-emited because team missed previous signal
	emit_signal("char_born")
	# Set Zombie skin
	if randi() % 4 == 0:
		model.setSkin("z2")
	else:
		model.setSkin("z1")
	
	connect("char_killed", self, "P_on_killed")
	model.connect("zm_attk_finished", self, "on_attk_completed")
	
	if get_tree().is_network_server():
		var navs = get_tree().get_nodes_in_group("Nav")
		if navs.size() == 1:
			nav = navs[0]
		else:
			Logger.LogError("_ready of zombie", "Problem with Navigation")
			print("Error at zombie")
		
		$navTimer.wait_time += rand_range(-0.5, 0.6)
		$navTimer.start()
		free_timer = Timer.new()
		free_timer.one_shot = true
		free_timer.wait_time = 8
		add_child(free_timer)
		free_timer.connect("timeout",self, "_on_free_timeout")
		connect("char_killed", self, "S_on_killed")


func _process(_delta):
	if get_tree().is_network_server() and alive:
		var T = game_server._unit_data_list.get(target_id)
		if T:
			if target_visible:
				movement_vector = (T.ref.position - position).normalized()
				rotation = movement_vector.angle() + PI / 2
			else:
				followPath()
				rotation = movement_vector.angle() + PI / 2


#get nearest unit
func getTarget():
	target_id = ""
	var units  = get_tree().get_nodes_in_group("Unit")
	
	var selected_unit = null
	var min_distance = 9999
	for i in units:
		if i.alive:
			var dist = (i.position - position).length()
			if dist < min_distance:
				min_distance = dist
				selected_unit = i
	
	if selected_unit:
		target_id = selected_unit.name
	
	getPathToTarget()


func getPathToTarget():
	var tar = game_server._unit_data_list.get(target_id)
	if tar:
		if game_states.is_Astar_ready():
			path_to_dest = nav.get_simple_path(position, tar.ref.position)
			cur_path_id = 0
			

func isTargetVisible(T) -> bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, T.position,
											[self], collision_mask)
	if result:
		if result.collider.name == T.name and T.alive:
			return true
	
	return false


func followPath():
	if cur_path_id >= path_to_dest.size():
		getPathToTarget()
	else:
		movement_vector = (path_to_dest[cur_path_id] - position).normalized()
		if (path_to_dest[cur_path_id] - position).length() < 10:
			cur_path_id += 1



func _on_navTimer_timeout():
	getTarget()
	var T = game_server._unit_data_list.get(target_id)
	if T:
		target_visible = isTargetVisible(T.ref)
		if target_visible and (T.ref.position - position).length() < 80:
			rpc("zmAttack")


func S_on_killed():
	free_timer.start()
	$navTimer.stop()
	

func P_on_killed():
	if randi() % 2 == 0:
		$body.show()
	else:
		$body2.show()
	
	$dtween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 6)
	$dtween.start()

func _on_free_timeout():
	rpc("P_freeZombie")


remotesync func P_freeZombie():
	team.removePlayer(self)
	queue_free()


#Function overide
func takeDamage(damage : float, _weapon : String, attacker_id : String):
	if not ( alive and get_tree().is_network_server() ):
		return
	
	var _attacker_data = game_server._unit_data_list.get(attacker_id)
	
	#reference to attacker
	var attacker_ref = null
	
	#Attacker exist.
	if _attacker_data:
		attacker_ref = _attacker_data.ref
		
		#emit blood splash
		_blood_splash(attacker_ref.position,position)
	
	#check if friendly fire
	if not (game_server.extraServerInfo.friendly_fire):
		if attacker_ref and team.team_id == attacker_ref.team.team_id:
			return
	

	HP -= damage
	
	emit_signal("char_took_damage")

	# sync with peers
	rpc_unreliable("P_health",HP,AP)
	# char dead
	if HP <= 0:
		game_server.rpc("P_handleKills", "Zombie",attacker_id, _weapon)
		
		if attacker_ref:
			attacker_ref.emit_signal("char_fraged")
		#sync with everyone
		rpc("P_death")
		

func _on_close_range_body_entered(_body):
	return

remotesync func zmAttack():
	model.doZmAttk()

func _on_close_range_body_exited(_body):
	return


func on_attk_completed():
	$zAttack.play()
	var T = game_server._unit_data_list.get(target_id)
	if T:
		T.ref.takeDamage(melee_damage, "Claw", "Zombie")
