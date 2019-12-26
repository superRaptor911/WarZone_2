extends Node
#holds index of turret 
#it acts as an unique id
var _turret_index : int  = 0

remote func _build_turret(type,pos,pl_name,turret_name):
	print("func _build_turret called")
	var turret = game_states.weaponResource.Turret.instance()
	turret.position = pos
	turret.gun_name = type
	turret.set_name(turret_name)
	var players = get_tree().get_nodes_in_group("User")
	
	for p in players:
		if p.name == pl_name:
			turret.maker = p
			break
	var lvl = get_tree().get_nodes_in_group("Level")[0]
	lvl.add_child(turret)

remote func build_turret(type,pos,pl_name):
	if get_tree().is_network_server():
		_turret_index += 1
		var turret_name = "turret_" + String(_turret_index)
		_build_turret(type,pos,pl_name,turret_name)
		rpc("_build_turret",type,pos,pl_name,turret_name)
	else:
		rpc_id(1,"build_turret",type,pos,pl_name) 