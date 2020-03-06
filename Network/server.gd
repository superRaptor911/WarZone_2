extends Node

var serverInfo := {
	"name": "Raptors LAN Game",
	"ip" : "127.0.0.1",
	"port" : "6969",
	"game_mode" : "FFA",
	"max_p" : "6",
	"map" : "",
}


#####################Update rate######################
var update_rate = 25 setget set_update_rate
var update_delta = 1.0 / update_rate setget no_set, get_update_delta

func set_update_rate(r):
	update_rate = r
	update_delta = 1.0 / update_rate

func get_update_delta():
	return update_delta

func no_set(r):
	pass

#################BUILDINGs##############

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

##############Loadings##############################

func _init_Particle(particle_name):
	var pos : Vector2 = Vector2(-9999,-9999)
	var a = load("res://Sprites/particles/" + particle_name + ".tscn").instance()
	a.position = pos
	get_tree().root.add_child(a)
	a.emitting = true

func preloadParticles():
	_init_Particle("bloodSplash")
	_init_Particle("bloodSpot")
	_init_Particle("explosion_cloud")
	


#######################Score board##############

#holds info of player that is to be shown on scoreboard
var _player_data = {
	id = 0,
	pname = "no_name",
	kills = 0,
	deaths = 0,
	ping = 0,
	score = 0,
	team_id = "A"
}

signal player_data_synced



var _player_data_list = Array()
var _kill_msg_list = Array()

func init_scoreBoard():
	_kill_msg_list.clear()

func addPlayer(pname,pid,team_id):
	var pd = _player_data.duplicate(true)
	pd.pname = pname
	pd.team_id = team_id
	pd.id = pid
	_player_data_list.append(pd)
	
func removePlayer(pid):
	var new_list = Array()
	for i in _player_data_list:
		if i.id != pid:
			new_list.append(i)
	_player_data_list = new_list

func handleKills(victim,killer,weapon_used):
	var victim_name = "someone"
	var killer_name = "someone"
	var kill_msg = ""
	#safe checks
	if victim:
		victim_name = victim.pname
		if victim.is_in_group("User"):
			var victim_data = _get_player_data_by_id(victim.id)
			victim_data.deaths += 1
	if killer:
		killer_name = killer.pname
		if killer.is_in_group("User"):
			var killer_data = _get_player_data_by_id(killer.id)
			killer_data.kills += 1
	if weapon_used:
		if weapon_used.gun_name == "plasma":
			kill_msg = victim_name + " was burned alive by hot plasma"
		elif weapon_used.gun_name == "explosive":
			kill_msg = killer_name + " exploded " + victim_name
		else:
			kill_msg = killer_name + " killed " + victim_name + " with " + weapon_used.gun_name
	else:
		kill_msg = killer_name + " killed " + victim_name
	
	if _kill_msg_list.size() > 15:
		_kill_msg_list.pop_front()
	_kill_msg_list.append(kill_msg)
	rpc_unreliable("sync_kill_msg",kill_msg)

remotesync func sync_kill_msg(kill_msg):
	var hud = get_tree().get_nodes_in_group("Hud")[0]
	hud.addKillMessage(kill_msg)
	
remote func ServerSyncPlayerDataList(requestPeerId : int):
	rpc_id(requestPeerId,"sync_player_data",_player_data_list)

remote func sync_player_data(player_data_list):
	_player_data_list = player_data_list
	emit_signal("player_data_synced")

func _get_player_data_by_id(id):
	for p in _player_data_list:
		if p.id == id:
			return p
	print("Server/Scoreboard : fatal error unable to find ",id)
