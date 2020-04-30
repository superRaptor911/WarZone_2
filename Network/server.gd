extends Node

var serverInfo := {
	"name": "Raptors LAN Game",
	"ip" : "127.0.0.1",
	"port" : "6969",
	"game_mode" : "FFA",
	"max_p" : "6",
	"map" : "",
}

#time is in minutes
var extraServerInfo = {
	friendly_fire = false,
	time_limit = 1,
	round_time = 2,
	max_wins = 8
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
	team_id = 0,
	pl_ref = null
}

signal player_data_synced



var _player_data_list : Dictionary
var _kill_msg_list = Array()

func resetPlayerData():
	_kill_msg_list.clear()
	_player_data_list.clear()


func addPlayer(pid : String,pl_ref):
	var pd = _player_data.duplicate(true)
	pd.pname = pl_ref.pname
	pd.team_id = pl_ref.team.team_id
	pd.id = pid
	pd.pl_ref = pl_ref
	_player_data_list[pid] = pd


func removePlayer(pid : String):
	_player_data_list.erase(pid)


#handle kill and death event
func handleKills(victim_id : String, killer_id : String, weapon_used : String):
	var victim = _player_data_list.get(victim_id)
	var killer = _player_data_list.get(killer_id)
	var kill_msg = ""
	
	var suicide = (victim_id == killer_id)
	var victim_name = ""
	var killer_name = ""
	#safe checks
	if victim:
		victim_name = victim.pname
		if victim.pl_ref.is_in_group("Unit"):
			victim.deaths += 1
			victim.score -= 1
			#Suicide case
			if suicide:
				victim.score -= 3
	if killer:
		killer_name = killer.pname
		if killer.pl_ref.is_in_group("Unit") and not suicide:
			killer.kills += 1
			killer.score += 4

	if suicide:
		kill_msg = victim_name + " did suicide"
	elif weapon_used == "":
		if weapon_used == "plasma":
			kill_msg = victim_name + " was burned alive by hot plasma"
		elif weapon_used == "explosive":
			kill_msg = killer_name + " exploded " + victim_name
		else:
			kill_msg = killer_name + " killed " + victim_name + " with " + weapon_used
	else:
		kill_msg = killer_name + " killed " + victim_name
	
	if _kill_msg_list.size() > 15:
		_kill_msg_list.pop_front()
	_kill_msg_list.append(kill_msg)
	rpc_unreliable("sync_kill_msg",kill_msg)


remotesync func sync_kill_msg(kill_msg):
	var hud = get_tree().get_nodes_in_group("Hud")
	if !hud.empty():
		hud[0].addKillMessage(kill_msg)
	
remote func ServerSyncPlayerDataList(requestPeerId : int):
	rpc_id(requestPeerId,"sync_player_data",_player_data_list)

remote func sync_player_data(player_data_list):
	_player_data_list = player_data_list
	emit_signal("player_data_synced")

func getUnitByID(id : String):
	var unit = _player_data_list.get(id)
	if unit:
		return unit.pl_ref
	print("Error player " + id + " not found")
	return null

###############################################################################
######BOT################BOT#############BOT##################################

var bot_settings = {
	bot_count = 0,
	bot_difficulty = 1,
	index = 0
}
