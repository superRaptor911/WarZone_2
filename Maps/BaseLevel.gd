extends Node2D

signal player_spawned(player)
signal player_despawned(player)

signal bot_spawned(bot)
signal bot_despawned(bot)

export var Level_Name = "no_name"
export var capture_mod = false

var team1 = preload("res://Objects/scripts/Team.gd").new(0,self)
var team2 = preload("res://Objects/scripts/Team.gd").new(1,self)

var teamSelector = preload("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
var spec_mode = preload("res://Objects/Game_modes/Spectate.tscn").instance()

var dropedItem_manager = preload("res://Objects/Misc/DropedItemManager.tscn").instance()

var spawned_pl_arr = Array()
var spawn_ponts = Array()

#character data dictionary for holding spawn information 
var char_data_dict = {
	pname = "player",
	name = "null",
	team_id = 1,
	pos = Vector2(0,0),
	skin = "",
	g1 = "",
	g2 = "",
	cur_gun = 0,
	is_bot = false
}

func _ready():
	MusicMan.music_player.volume_db = -10.0
	if capture_mod:
		captureMap()
		return
	
	game_server.resetPlayerData()
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

func captureMap():
	var size = $BaseMap/height.get_used_rect().size * Vector2(64,64)
	OS.window_size = size / Vector2(8,8)
	var max_xy = min(size.x,size.y)
	var ratio
	if max_xy == size.x:
		ratio = OS.window_size.x / max_xy
	else:
		ratio = OS.window_size.y / max_xy
	
	self.scale = Vector2(ratio,ratio)
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# Retrieve the captured Image using get_data()
	var img = get_viewport().get_texture().get_data()
	# Flip on the y axis
	# You can also set "V Flip" to true if not on the Root Viewport
	img.flip_y()
	# Convert Image to ImageTexture
	img.save_png("res://Maps/" + Level_Name + "/minimap.png")


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
	#bad code
	if get_tree().is_network_server():
		rpc("spawn_player", game_states.player_info, getSpawnPosition(selected_team), selected_team)
	else:
		rpc_id(1,"serverSpawnMyPlayer",game_states.player_info,selected_team)
	$CanvasLayer.remove_child(teamSelector)

func _on_player_removed(pinfo):
	despawn_player(pinfo)


func getSpawnPosition(team_id : int) -> Vector2:
	if spawn_ponts.empty():
		print("Error : No spawn points available")
	else:
		var best_spawn_point = null
		var min_value = 999
		
		for i in spawn_ponts:
			if (i.team_id == -1 or i.team_id == team_id) and i.entity_count < min_value:
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
		char_data.skin = i.skin.model_name
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
		char_data.skin = i.skin.model_name
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
	if spawned_pl_arr.has(int(char_data.name)) or char_data.pos == game_states.invalid_position:
		print_debug("Fatal network spawn error : player already exist")
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
	
	#assign player a team
	if char_data.team_id == team1.team_id:
		team1.addPlayer(nactor)
	elif char_data.team_id == team2.team_id:
		team2.addPlayer(nactor)
	else:
		print_debug("Fatal Error: invalid team id for player ", char_data.pname)
	
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (int(char_data.name) != 1):
		if not char_data.is_bot:
			nactor.set_network_master(int(char_data.name))
		game_server.addPlayer(char_data.name,nactor)
		spawned_pl_arr.push_back(int(char_data.name))
	else:
		game_server.addPlayer(String(1),nactor)
		spawned_pl_arr.push_back(1)
		
	nactor.setSkin(game_states.modelResource.get(char_data.skin).instance())
	add_child(nactor)
	if not char_data.is_bot:
		emit_signal("player_spawned",nactor)
	else:
		emit_signal("bot_spawned",nactor)


#legacy spawn function
remotesync func spawn_player(pinfo, pos : Vector2, team : int):
	if spawned_pl_arr.has(pinfo.net_id) or pos == game_states.invalid_position:
		print_debug("Fatal network spawn error : player already exist")
		return
	spawned_pl_arr.push_back(pinfo.net_id)
	var nactor = game_states.classResource.player.instance()
	nactor.position = pos
	nactor.load_guns(pinfo.primary_gun_name,pinfo.sec_gun_name)
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))
	
	nactor.pname = pinfo.name
	nactor.id = pinfo.net_id
	var skin
	if team == team1.team_id:
		team1.addPlayer(nactor)
		skin = game_states.modelResource.get(pinfo.t_model).instance()
	elif team == team2.team_id:
		team2.addPlayer(nactor)
		skin = game_states.modelResource.get(pinfo.ct_model).instance()
	
	nactor.selected_gun = nactor.primary_gun
	nactor.setSkin(skin)
	game_server.addPlayer(String(pinfo.net_id),nactor)
	add_child(nactor)
	emit_signal("player_spawned",nactor)


func spawnBots():
	var bots : Array
	var bot_count = game_server.bot_settings.bot_count
	game_server.bot_settings.index = 0
	var ct = false
	
	if bot_count > game_states.bot_profiles.bot.size():
		print("error not enough bot profiles")
	
	for i in game_states.bot_profiles.bot:
		i.is_in_use = false
		if game_server.bot_settings.index < bot_count:
			i.is_in_use = true
			var char_data = char_data_dict.duplicate(true)
			char_data.pname = "bot_" + i.bot_name
			char_data.g1 = i.bot_primary_gun
			char_data.g2 = i.bot_sec_gun
			char_data.is_bot = true
			
			#assign team
			if ct:
				char_data.team_id = 1
				char_data.skin = i.bot_ct_skin
				ct = false
			else:
				char_data.team_id = 0
				char_data.skin = i.bot_t_skin
				ct = true
			
			char_data.pos = getSpawnPosition(char_data.team_id)
			#giving unique integer name
			char_data.name = String(69 + game_server.bot_settings.index)
			bots.append(char_data)
			game_server.bot_settings.index += 1
	
	#spawn bot
	for i in bots:
		spawnPlayer(i)

#spawn a single bot to requested team
func spawnBot(team_id : int = 0):
	#result of operation
	var result = false
	for i in game_states.bot_profiles.bot:
		#check if profile is in use or not
		if not i.is_in_use:
			print("spawning " + i.bot_name)
			i.is_in_use = true
			var char_data = char_data_dict.duplicate(true)
			char_data.pname = i.bot_name
			char_data.g1 = i.bot_primary_gun
			char_data.g2 = i.bot_sec_gun
			char_data.is_bot = true
			
			#assign team
			if team_id == 1:
				char_data.team_id = 1
				char_data.skin = i.bot_ct_skin
			else:
				char_data.team_id = 0
				char_data.skin = i.bot_t_skin
				
			char_data.pos = getSpawnPosition(char_data.team_id)
			#giving unique integer name
			char_data.name = String(69 + game_server.bot_settings.index)
			game_server.bot_settings.index += 1
			spawnPlayer(char_data)
			result = true
			break
	
	if not result:
		print("unable to add bot no profile available")


func server_kickBot(bot):
	if get_tree().is_network_server():
		for i in game_states.bot_profiles.bot:
			if i.bot_name == bot.pname:
				i.is_in_use = false
				print("Removing bot ",i.bot_name)
				rpc("kickBot",bot.name)
				return
	print_debug("Error Unable to kick bot ", bot.pname)


remotesync func kickBot(bot_name):
	var bot = get_node(bot_name)
	if bot:
		emit_signal("bot_despawned",bot)
		bot.queue_free()
	else:
		print("Fatal:Cannot remove invalid node from tree")

func kickAllBot():
	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		server_kickBot(i)

remote func despawn_player(pinfo):
	if (get_tree().is_network_server()):
		for id in network.players:
			if (id == pinfo.net_id || id == 1):
				continue
			rpc_id(id, "despawn_player", pinfo)
	
	var player_node = get_node(str(pinfo.net_id))
	if (!player_node):
		print_debug("Cannot remove invalid node from tree")
		return
	emit_signal("player_despawned",player_node)
	player_node.queue_free()


func _on_disconnected():
	MenuManager.changeScene("summary")
	queue_free()
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")



#stops the server
func Server_stopLevel():
	if get_tree().is_network_server():
		rpc("stopLevel")
		#reset bot profile
		for i in game_states.bot_profiles.bot:
			i.is_in_use = false
	else:
		print_debug("Error not server")


#client func
remotesync func stopLevel():
	var chars = get_tree().get_nodes_in_group("Actor")
	for i in chars:
		i.queue_free()
	spawned_pl_arr.clear()


func Server_startLevel():
	if get_tree().is_network_server():
		rpc("startLevel")
		spawnBots()
	else:
		print_debug("Error not server")


remotesync func startLevel():
	game_server.resetPlayerData()
	team1.reset()
	team2.reset()
	$CanvasLayer.add_child(teamSelector)


func Server_restartLevel():
	if get_tree().is_network_server():
		rpc("restartLevel")
		#reset bot profile
		for i in game_states.bot_profiles.bot:
			i.is_in_use = false
		spawnBots()
	else:
		print_debug("Error not server")


remotesync func restartLevel():
	var chars = get_tree().get_nodes_in_group("Actor")
	for i in chars:
		i.queue_free()
	spawned_pl_arr.clear()
	game_server.resetPlayerData()
	team1.reset()
	team2.reset()
	$CanvasLayer.add_child(teamSelector)
