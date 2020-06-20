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
	
	if not get_tree().is_network_server():
		return

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
	add_child(free_timer)
	free_timer.connect("timeout",self, "_on_free_timeout")
	
	connect("char_killed", self, "_on_killed")


func _process(_delta):
	if get_tree().is_network_server():
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


func _on_killed():
	free_timer.start()
	
	

func _on_free_timeout():
	rpc("P_freeZombie")


remotesync func P_freeZombie():
	queue_free()
