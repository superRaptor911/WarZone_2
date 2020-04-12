extends Node2D

signal player_spawned(player)
signal player_despawned(player)

signal bot_spawned(bot)
signal bot_despawned(bot)

export var Level_Name = "no_name"

var team1 = preload("res://Objects/scripts/Team.gd").new(0,self)
var team2 = preload("res://Objects/scripts/Team.gd").new(1,self)

var teamSelector = preload("res://Objects/Game_modes/FFA/FFATeamSelect.tscn").instance()
var spec_mode = preload("res://Objects/Game_modes/Spectate.tscn").instance()

var dropedItem_manager = preload("res://Objects/Misc/DropedItemManager.tscn").instance()

var arr = Array()
var spawn_ponts = Array()

#character data dictionary for holding spawn information 
var char_data_dict = {
	pname = "player",
	name = "null",
	team_id = 1,
	pos = Vector2(0,0),
	g1 = "",
	g2 = "",
	cur_gun = 0,
	is_bot = false
}

func _ready():
	add_child(team1)
	add_child(team2)
	add_child(dropedItem_manager)
	loadGameMode()
	game_server._player_data_list.clear()
	spawn_ponts = get_tree().get_nodes_in_group("SpawnPoint")
	$CanvasLayer.add_child(teamSelector)
	network.connect("disconnected", self, "_on_disconnected")
	teamSelector.connect("team_selected",self,"_on_player_selected_team")
	teamSelector.connect("spectate_mode",self,"_on_specmode_selected")
	spec_mode.connect("leave_spec_mode",self,"_on_spec_mode_leave")
	
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")
		spawnBots()
	else:
		rpc_id(1,"serverGetPlayers", game_states.player_info.net_id)


func loadGameMode():
	var game_mode = null
	#load appropriate game mode
	print(game_server.serverInfo.game_mode)
	if game_server.serverInfo.game_mode == "SURVIVAL":
		game_mode = load("res://Objects/Game_modes/SURVIVAL_mode.tscn").instance()
	elif game_server.serverInfo.game_mode == "FFA":
		game_mode = load("res://Objects/Game_modes/FFA_mode.tscn").instance()
	elif game_server.serverInfo.game_mode == "Bombing":
		game_mode = load("res://Objects/Game_modes/BombDiffuse.tscn").instance()
	#add game mode
	if game_mode:
		var mode_res = load($level_info.getGameModeNodePath()).instance()
		game_mode.add_to_group("GameMode")
		add_child(mode_res)
		add_child(game_mode)
		


func _on_specmode_selected():
	add_child(spec_mode)
	$CanvasLayer.remove_child(teamSelector)

func _on_spec_mode_leave():
	remove_child(spec_mode)
	$CanvasLayer.add_child(teamSelector)

func _on_player_selected_team(selected_team):
	_init_game()
	#bad code
	if get_tree().is_network_server():
		rpc("spawn_player", game_states.player_info, getSpawnPosition(selected_team), selected_team)
	else:
		rpc_id(1,"serverSpawnMyPlayer",game_states.player_info,selected_team)
	teamSelector.queue_free()

func _on_player_removed(pinfo):
	despawn_player(pinfo)


func getSpawnPosition(team_id : int) -> Vector2:
	if spawn_ponts.empty():
		print("Error : No spawn points available")
	else:
		var best_spawn_point = null
		var min_value = 999
		
		for i in spawn_ponts:
			if (game_server.serverInfo.game_mode == "FFA" or i.team_id == -1
			or i.team_id == team_id) and i.entity_count < min_value:
				min_value = i.entity_count
				best_spawn_point = i
		
		if best_spawn_point != null:
			return best_spawn_point.getPoint()
		else:
			print("Error : No spawn point for selected team")
	return game_states.invalid_position


#get player data from server
#server only function
remote func serverGetPlayers(peer_id):
	#get spawned players
	var spawned_chars = get_tree().get_nodes_in_group("User")
	var char_data_list = Array()
	#fillup data of players
	for i in spawned_chars:
		var char_data = char_data_dict.duplicate(true)
		char_data.name = i.name
		char_data.team_id = i.team.team_id
		char_data.pos = i.position
		char_data.g1 = i.primary_gun.gun_name
		char_data.g2 = i.sec_gun.gun_name
		char_data.is_bot = false
		if i.selected_gun == i.primary_gun:
			char_data.cur_gun = 0
		else:
			char_data.cur_gun = 1
		char_data_list.append(char_data)
		
	spawned_chars = get_tree().get_nodes_in_group("Bot")
	#fillup data of Bots
	for i in spawned_chars:
		var char_data = char_data_dict.duplicate(true)
		char_data.name = i.name
		char_data.team_id = i.team.team_id
		char_data.pos = i.position
		char_data.g1 = i.primary_gun.gun_name
		char_data.g2 = i.sec_gun.gun_name
		char_data.is_bot = true
		if i.selected_gun == i.primary_gun:
			char_data.cur_gun = 0
		else:
			char_data.cur_gun = 1
		char_data_list.append(char_data)
	#send data to peer
	rpc_id(peer_id,"peerSpawnPlayers", char_data_list)

remote func serverSpawnMyPlayer(pinfo,team):
	if get_tree().is_network_server():
		rpc("spawn_player",pinfo,getSpawnPosition(team),team)
	else:
		print("Error : not server")

remote func peerSpawnPlayers(player_dict):
	for i in player_dict:
		spawnPlayer(i)

#spawn an individual player
func spawnPlayer(char_data):
	if arr.has(int(char_data.name)) or char_data.pos == game_states.invalid_position:
		print("Fatal network spawn error")
		return
	var nactor
	if char_data.is_bot:
		nactor = game_states.classResource.bot.instance()
		nactor.bot_data.bot_g1 = char_data.g1
		nactor.bot_data.bot_g2 = char_data.g2
	else:
		nactor = game_states.classResource.player.instance()
	nactor.position = char_data.pos
	nactor.set_name(char_data.name)
	nactor.load_guns(char_data.g1, char_data.g2)
	nactor.pname = char_data.pname
	nactor.id = int(char_data.name)
	nactor.set_name(char_data.name)
	if char_data.cur_gun == 0:
		nactor.selected_gun = nactor.primary_gun
	else:
		nactor.selected_gun = nactor.sec_gun
	
	
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (int(char_data.name) != 1):
		if not char_data.is_bot:
			nactor.set_network_master(int(char_data.name))
		game_server.addPlayer(char_data.pname, int(char_data.name), char_data.team_id)
		arr.push_back(int(char_data.name))
	else:
		game_server.addPlayer(char_data.pname, 1, char_data.team_id)
		arr.push_back(1)
	
	#assign player a team
	if char_data.team_id == team1.team_id:
		team1.addPlayer(nactor)
	elif char_data.team_id == team2.team_id:
		team2.addPlayer(nactor)
	else:
		print("Fatal Error: invalid team id for player ", char_data.pname)
	add_child(nactor)
	if not char_data.is_bot:
		emit_signal("player_spawned",nactor)
	else:
		emit_signal("bot_spawned",nactor)


#legacy spawn function
remotesync func spawn_player(pinfo, pos : Vector2, team : int):
	if arr.has(pinfo.net_id) or pos == game_states.invalid_position:
		print("Fatal network spawn error")
		return
	arr.push_back(pinfo.net_id)
	var nactor = game_states.classResource.player.instance()
	nactor.position = pos
	nactor.load_guns(pinfo.primary_gun_name,pinfo.sec_gun_name)
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))
	
	nactor.pname = pinfo.name
	nactor.id = pinfo.net_id
	game_server.addPlayer(pinfo.name, pinfo.net_id,team)
	if team == team1.team_id:
		team1.addPlayer(nactor)
	elif team == team2.team_id:
		team2.addPlayer(nactor)
	
	nactor.selected_gun = nactor.primary_gun
	add_child(nactor)
	emit_signal("player_spawned",nactor)


func spawnBots():
	var index : int = 0
	var bots : Array
	
	for i in game_states.bot_profiles.bot:
		if index == game_server.bot_settings.bot_count:
			break
		print("spawning " + i.bot_name)
		var char_data = char_data_dict.duplicate(true)
		char_data.pname = "bot_" + i.bot_name
		char_data.g1 = i.bot_primary_gun
		char_data.g2 = i.bot_sec_gun
		char_data.is_bot = true
		char_data.team_id = 1
		char_data.pos = getSpawnPosition(char_data.team_id)
		#giving unique integer name
		char_data.name = String(69 + index)
		bots.append(char_data)
		index += 1
	for i in bots:
		spawnPlayer(i)


remote func despawn_player(pinfo):
	if (get_tree().is_network_server()):
		for id in network.players:
			if (id == pinfo.net_id || id == 1):
				continue
			rpc_id(id, "despawn_player", pinfo)
	
	var player_node = get_node(str(pinfo.net_id))
	if (!player_node):
		print("Cannot remove invalid node from tree")
		return
	emit_signal("player_despawned",player_node)
	player_node.queue_free()


func _on_disconnected():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")
	queue_free()


func _init_game():
	game_server.init_scoreBoard()

