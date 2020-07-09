extends Node

var serverInfo : = {
	"name": "Raptors LAN Game",
	"ip" : "127.0.0.1",
	"port" : "6969",
	"game_mode" : "FFA",
	"max_p" : "6",
	"map" : "",
	"version" : game_states.current_game_version,
	"min_v" : 1.33
}

#time is in minutes
var extraServerInfo = {
	friendly_fire = false,
	kill_messages = true,
	time_limit = 6,
	round_time = 2,
	max_wins = 8,
	bot_differ_to_user = false,
	auto_teambalance = true,
	tick_rate = 25
}


#####################Update rate######################
var update_rate = 25 setget set_update_rate
var update_delta = 1.0 / update_rate setget no_set, get_update_delta

func set_update_rate(r):
	update_rate = r
	update_delta = 1.0 / update_rate

func get_update_delta():
	return update_delta

func no_set(_r):
	pass



#######################Score board##############

#holds info of player that is to be shown on scoreboard
var _unit_data = {
	p = 0,			#ping
	ref = null		#Reference
}


var _unit_data_list : Dictionary
var _kill_msg_list = Array()

func resetUnitData():
	_kill_msg_list.clear()
	_unit_data_list.clear()


func addUnit(ref : Unit):
	var pd = _unit_data.duplicate(true)
	pd.ref = ref
	_unit_data_list[ref.name] = pd

func removeUnit(pid : String):
	_unit_data_list.erase(pid)


#handle kill and death event and show it in HUD
remotesync func handleKills(victim_id : String, killer_id : String, _weapon_used : String):
	var victim = _unit_data_list.get(victim_id)
	var killer = _unit_data_list.get(killer_id)
	var kill_msg = ""
	
	var suicide = (victim_id == killer_id)
	var victim_name = ""
	var killer_name = ""
	#safe checks
	if victim:
		victim_name = victim.ref.pname
		if victim.ref.is_in_group("Unit"):
			victim.ref.deaths += 1
			victim.ref.score -= 1
			#Suicide case
			if suicide:
				victim.ref.score -= 3
	else:
		victim_name = victim_id
		Logger.Log("--> Victim %s not found" % [victim_id])

	if killer:
		killer_name = killer.ref.pname
		if killer.ref.is_in_group("Unit") and not suicide:
			killer.ref.kills += 1
			killer.ref.score += 4
	else:
		killer_name = killer_id
		Logger.Log("--> Killer %s not found" % [killer_id])

	if suicide:
		kill_msg = victim_name + " did suicide"
	else:
		kill_msg = killer_name + " killed " + victim_name
	
	if _kill_msg_list.size() > 15:
		_kill_msg_list.pop_front()
	_kill_msg_list.append(kill_msg)

	var hud = get_tree().get_nodes_in_group("Hud")
	if !hud.empty():
		hud[0].addKillMessage(kill_msg)


func getUnitByID(id : String) -> Dictionary:
	var unit = _unit_data_list.get(id)
	if not unit:
		print_debug("player " + id + " not found")
	return unit


###############################################################################
######BOT################BOT#############BOT##################################

var bot_settings = {
	bot_count = 0,
	bot_difficulty = 1,
	index = 0
}
