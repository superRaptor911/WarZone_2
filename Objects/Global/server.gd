extends Node

var use_server_advertiser = true

# Server configuration
var serverInfo : = {
	"name": "Raptors LAN Game",
	"ip" : "127.0.0.1",
	"port" : "6969",
	"game_mode" : "",
	"max_p" : "6",
	"map" : "",
	"map_author" : "INC",
	"version" : game_states.current_game_version,
	"min_v" : 1.48
}

# Time is in minutes
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


var game_config = {
	override_default_spectator = false,
	overide_default_team_selector = false,
	overide_default_HUD = false
}

# settings for game modes (like time limit, round limit . . .)
var game_mode_settings = {}

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


###############################################################################
signal synced_serverInfo

remote func getServerInfo(peer_id):
	rpc_id(peer_id, "syncServerInfo", serverInfo)
	print("Sending sever configuration to peer ", peer_id)


remote func syncServerInfo(s_info):
	serverInfo = s_info
	print("Got Server Configuration from server")
	emit_signal("synced_serverInfo")


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
	
func getLocalPlayer():
	return _unit_data_list.get(String(game_states.player_info.net_id))


################################################################################
############## Kill Msg ########################################################
################################################################################

var wpn_kill_icons = {
	default_gun = "res://Sprites/Weapons/elite_k.png",
	AK47 = "res://Sprites/Weapons/ak47_k.png",
	Aug = "res://Sprites/Weapons/aug_k.png",
	Awm = "res://Sprites/Weapons/awp_k.png",
	deagle = "res://Sprites/Weapons/deagle_k.png",
	MP5 = "res://Sprites/Weapons/mp5_k.png",
	Famas = "res://Sprites/Weapons/famas_k.png",
	M4A1 = "res://Sprites/Weapons/m4a1_k.png",
	P90 = "res://Sprites/Weapons/p90_k.png",
	G3S1 = "res://Sprites/Weapons/g3sg1_k.png",
	Galil = "res://Sprites/Weapons/galil_k.png",
	M249 = "res://Sprites/Weapons/m249_k.png",
	mac10 = "res://Sprites/Weapons/mac10_k.png",
	Claw = "res://Sprites/Weapons/claw_k.png"
}

var bbcode_format_good = "[color=green][b]%s[/b][/color] [img]%s[/img][color=red][b] %s[/b][/color]"
var bbcode_format_bad = "[color=red][b]%s[/b][/color] [img]%s[/img][color=green][b] %s[/b][/color]"


func getKillIcon(wpn_name : String) -> String:
	var rtn_val = wpn_kill_icons.get(wpn_name)
	if not rtn_val:
		rtn_val = "res://Sprites/Weapons/claw_k.png"
	return rtn_val


#handle kill and death event and show it in HUD
remotesync func P_handleKills(victim_id : String, killer_id : String, weapon_used : String):
	var victim = _unit_data_list.get(victim_id)
	var killer = _unit_data_list.get(killer_id)
	var kill_msg = ""
	
	var is_killer_friend = false
	
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
		#Verify killer is our friend
		var local_plr = getLocalPlayer()
		is_killer_friend = (local_plr && (local_plr.ref.team.team_id == killer.ref.team.team_id))
		
		if killer.ref.is_in_group("Unit") and not suicide:
			killer.ref.kills += 1
			killer.ref.score += 4
	else:
		killer_name = killer_id
		Logger.Log("--> Killer %s not found" % [killer_id])

	if suicide:
		if game_states.game_settings.use_rich_text:
			if is_killer_friend:
				kill_msg = bbcode_format_good % [victim_name, getKillIcon(weapon_used), "self"]
			else:
				kill_msg = bbcode_format_bad % [victim_name, getKillIcon(weapon_used), "self"]
		else:
			kill_msg = victim_name + " killed self"
	else:
		if game_states.game_settings.use_rich_text:
			if is_killer_friend:
				kill_msg = bbcode_format_good % [killer_name, getKillIcon(weapon_used), victim_name]
			else:
				kill_msg = bbcode_format_bad % [killer_name, getKillIcon(weapon_used), victim_name]
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


################################################################################
################################################################################
###############SYSADMIN###########SYSADMIN######################################

#Utiltiy#######################################################################

func messageAdmin(msg):
	if get_tree().is_network_server() and network.sysAdmin_online:
		Logger.rpc_id(int(network.sysAdmin_id), "remoteMsg", msg)



remote func S_changeLevelTo(level_name : String, game_mode : String):
	if get_tree().is_network_server():
		rpc("P_changeLevelTo", level_name, game_mode)


# Function to change Level
remotesync func P_changeLevelTo(level_name : String, game_mode : String):
	if game_states.is_sysAdmin:
		return
	var all_ok = false
	var level_info = load("res://Maps/level_info.gd").new()
	var levels : Array = level_info.levels.values()
	var scn = null
	
	for i in levels:
		if i.name == level_name:
			var modes_count = i.game_modes.size() / 2
			for j in range(modes_count):
				if i.game_modes[j * 2] == game_mode:
					all_ok = true
					scn = i.game_modes[j * 2 + 1]
	
	if not all_ok:
		Logger.Log("Error: Unable to find level %s with game mode %s" % [level_name, game_mode])
		messageAdmin("Error: Unable to find level %s with game mode %s" % [level_name, game_mode])
		return
	
	Logger.Log("Changing level to %s (%s)" % [level_name, game_mode])
	messageAdmin("Changing level to %s (%s)" % [level_name, game_mode])
	var level_nodes = get_tree().get_nodes_in_group("Level")
	if not level_nodes.empty():
		var cur_level = level_nodes[0]
		Logger.Log("Freeing current Level")
		messageAdmin("Freeing current Level")
		cur_level.queue_free()
	
	Logger.Log("Loading new level")
	messageAdmin("Loading new level")
	serverInfo.map = level_name
	serverInfo.game_mode = game_mode
	get_tree().change_scene(scn)
	
	if get_tree().is_network_server() and network.sysAdmin_online:
		messageAdmin("Level changed to \"%s\"." % [serverInfo.map])
		messageAdmin("current level : %s current mode %s" % [serverInfo.map, serverInfo.game_mode])
		rpc_id(int(network.sysAdmin_id), "A_levelChange_confirmation", serverInfo)



remote func A_levelChange_confirmation(new_serverInfo):
	serverInfo = new_serverInfo


remote func S_getBotCount():
	messageAdmin("Bot count = %d" %[get_tree().get_nodes_in_group("Bot").size()])


remote func S_getPlayerCount():
	messageAdmin("Player count = %d" %[get_tree().get_nodes_in_group("User").size()])


remote func S_getAvailableMaps():
	var level_info = load("res://Maps/level_info.gd").new()
	var levels : Array = level_info.levels.values()
	var lvl_names = ""
	for i in levels:
		lvl_names += i.name + "\n"
	
	messageAdmin("Available Levels :-\n %s" %[lvl_names])
	level_info.queue_free()
	

remote func S_getIP():
	var ips = ""
	for i in IP.get_local_addresses():
		ips += i + "\n"
	messageAdmin(ips)
