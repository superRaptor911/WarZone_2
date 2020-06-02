extends Node2D

signal player_created(player)
signal player_removed(player)

signal bot_created(bot)
signal bot_removed(bot)

export var Level_Name = "no_name"
export var capture_mod = false

var team1 = preload("res://Objects/scripts/Team.gd").new(0,self)
var team2 = preload("res://Objects/scripts/Team.gd").new(1,self)

var teamSelector = preload("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
var spec_mode = preload("res://Objects/Game_modes/Spectate.tscn").instance()
var dropedItem_manager = preload("res://Objects/Misc/DropedItemManager.tscn").instance()

var spawned_units = Array()
var spawn_ponts = Array()

#Unit attiributes
var unit_data_dict = {
	n = "",			#node name
	pn = "",		#name
	p = Vector2(),	#position
	b = false,		#is bot?
	g1 = "",		#gun1 (current)
	g2 = "",		#gun2 (current)
	tId = 0,		#team id
	s = "",			#skin name
	cg = 0,			#current gun , 0 = primary , 1 = secondary
	k = 0,			#kills
	d = 0,			#deaths
	scr = 0,		#score
	pg = "",		#primary gun
	sg = "",		#secondary gun
}

var spawned_units_ids = Array()

func _ready():
	MusicMan.music_player.stop()

	if capture_mod:
		captureMap()
		return
	
	game_server.resetUnitData()
	
	#setup teams
	add_child(team1)
	add_child(team2)
	add_child(dropedItem_manager)
	loadGameMode()
	game_server._unit_data_list.clear()
	spawn_ponts = get_tree().get_nodes_in_group("SpawnPoint")
	network.connect("disconnected", self, "_on_disconnected")
	
	#handle team selector
	$CanvasLayer.add_child(teamSelector)
	teamSelector.connect("team_selected",self,"_on_player_selected_team")
	teamSelector.connect("spectate_mode",self,"_on_specmode_selected")
	spec_mode.connect("leave_spec_mode",self,"_on_spec_mode_leave")
	
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")
		createBots()
	else:
		rpc_id(1,"S_getExistingUnits", game_states.player_info.net_id)

#this is used to capture minimap
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
	Logger.Log("Loading gamemode %s" % [game_server.serverInfo.game_mode])
	
	#load appropriate game mode	
	if game_server.serverInfo.game_mode == "SURVIVAL":
		game_mode = load("res://Objects/Game_modes/SURVIVAL_mode.tscn").instance()
	elif game_server.serverInfo.game_mode == "FFA":
		game_mode = load("res://Objects/Game_modes/FFA_mode.tscn").instance()
	elif game_server.serverInfo.game_mode == "Bombing":
		game_mode = load("res://Objects/Game_modes/BombDiffuse.tscn").instance()
	
	#add game mode
	if game_mode:
		Logger.Log("Loading Level resource from %s" % [$level_info.getGameModeNodePath()])
		var mode_res = load($level_info.getGameModeNodePath()).instance()
		game_mode.add_to_group("GameMode")
		add_child(mode_res)
		add_child(game_mode)
		

func _on_specmode_selected():
	Logger.Log("[%s] selected spectate" % [game_states.player_info.name])
	add_child(spec_mode)
	$CanvasLayer.remove_child(teamSelector)

func _on_spec_mode_leave():
	remove_child(spec_mode)
	$CanvasLayer.add_child(teamSelector)

func _on_player_selected_team(selected_team):
	if get_tree().is_network_server():
		rpc_id(1,"S_createPlayer",game_states.player_info,selected_team)
	$CanvasLayer.remove_child(teamSelector)

#When a player disconnects
func _on_player_removed(pinfo):
	S_removeUnit(String(pinfo.net_id))


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

#get data from server
remote func S_getExistingUnits(peer_id : String):
	Logger.Log("Sending existing player data to [%s] " % [peer_id])
	#get spawned players
	var units = get_tree().get_nodes_in_group("Unit")
	var data_list = Array()
	#fillup data of players
	for i in units:
		var data = unit_data_dict.duplicate(true)
		data.n = i.name
		data.tId = i.team.team_id
		data.p = i.position
		data.g1 = i.gun_1.gun_name
		data.g2 = i.gun_2.gun_name
		data.s = i.model.skin_name
		data.b = i.is_in_group("Bot")
		data.pn = i.pname
		data.k = i.kills
		data.d = i.deaths
		data.scr = i.score
		data.pg = i.prim_gun
		data.sg = i.sec_gun
		if i.selected_gun == i.gun_1:
			data.cg = 0
		else:
			data.cg = 1
		data_list.append(data)
		
	#send data to peer
	rpc_id(int(peer_id), "P_createUnits", data_list)

#create player , server side 
remotesync func S_createPlayer(pinfo,team : int):
	assert(get_tree().is_network_server(),"Not server")
	rpc("P_createPlayer",pinfo,getSpawnPosition(team),team)


#create player, client
remotesync func P_createPlayer(pinfo, pos : Vector2, team_id : int):
	var data = unit_data_dict.duplicate(true)
	data.n = String(pinfo.net_id)
	data.pn = pinfo.name
	data.p = pos
	data.tId = team_id
	data.g1 = pinfo.primary_gun_name
	data.g2 = pinfo.sec_gun_name
	data.s = pinfo.t_model
	data.cg = 0
	data.k = 0
	data.d = 0
	data.scr = 0
	data.pg = pinfo.primary_gun_name
	data.sg = pinfo.sec_gun_name

	if team_id == 1:
		data.s = pinfo.ct_model
	
	createUnit(data)
	

#create multiple players, client side
remote func P_createUnits(player_dict):
	for i in player_dict:
		createUnit(i)


#Function to create an Unit
func createUnit(data):
	assert(!spawned_units_ids.has(data.n), "Duplicate Unit found")
	var unit
	if data.b:
		unit = game_states.classResource.bot.instance()
		unit.bot_data.bot_g1 = data.g1
		unit.bot_data.bot_g2 = data.g2
	else:
		unit = game_states.classResource.player.instance()
	unit.position = data.p
	unit.name = data.n
	unit.pname = data.pn
	unit.kills = data.k
	unit.deaths = data.d
	unit.prim_gun = data.pg
	unit.sec_gun = data.sg
	unit.score = data.scr
	
	assert(data.tId <= 1)
	#assign player a team
	if data.tId == team1.team_id:
		team1.addPlayer(unit)
	elif data.tId == team2.team_id:
		team2.addPlayer(unit)
	
	# If this actor does not belong to the server, change the node name and network master accordingly
	if data.n != "1":
		if not data.b:
			unit.set_network_master(int(data.n))
		game_server.addUnit(unit)
		spawned_units_ids.push_back(unit.name)
	else:
		game_server.addUnit(unit)
		spawned_units_ids.push_back(unit.name)
	
	unit.get_node("Model").setSkin(data.s)
	add_child(unit)
	unit.loadGuns(data.g1, data.g2)
	
	if data.cg == 1:
		unit.switchToSecondaryGun()

	if not data.b:
		emit_signal("player_created",unit)
	else:
		emit_signal("bot_created",unit)
		print("bot created")


func createBots():
	Logger.Log("Creating bots")
	var bots = Array()
	var bot_count = game_server.bot_settings.bot_count
	game_server.bot_settings.index = 0
	var ct = false
	
	if bot_count > game_states.bot_profiles.bot.size():
		Logger.Log("Not enough bot profiles. Required %d , Got %d" % [bot_count, game_states.bot_profiles.bot.size()])
	
	for i in game_states.bot_profiles.bot:
		i.is_in_use = false
		if game_server.bot_settings.index < bot_count:
			i.is_in_use = true
			var data = unit_data_dict.duplicate(true)
			data.pn = i.bot_name
			data.g1 = i.bot_primary_gun
			data.g2 = i.bot_sec_gun
			data.b = true
			data.k = 0
			data.d = 0
			data.scr = 0
			data.pg = i.bot_primary_gun
			data.sg = i.bot_sec_gun
			
			#assign team
			if ct:
				data.tId = 1
				data.s = i.bot_ct_skin
				ct = false
			else:
				data.tId = 0
				data.s = i.bot_t_skin
				ct = true
			
			data.pos = getSpawnPosition(data.tId)
			#giving unique node name
			data.n = "bot" + String(69 + game_server.bot_settings.index)
			bots.append(data)
			game_server.bot_settings.index += 1
	
	#spawn bot
	for i in bots:
		createUnit(i)
		Logger.Log("Created bot [%s] with ID %s" % [i.pn, i.n])


#spawn a single bot to requested team
func spawnBot(team_id : int = 0):
	#result of operation
	var result = false
	for i in game_states.bot_profiles.bot:
		#check if profile is in use or not
		if not i.is_in_use:
			i.is_in_use = true
			var data = unit_data_dict.duplicate(true)
			data.pn = i.bot_name
			data.g1 = i.bot_primary_gun
			data.g2 = i.bot_sec_gun
			data.b = true
			data.k = 0
			data.d = 0
			data.scr = 0
			data.pg = i.bot_primary_gun
			data.sg = i.bot_sec_gun

			#assign team
			if team_id == 1:
				data.tId = 1
				data.s = i.bot_ct_skin
			else:
				data.tId = 0
				data.s = i.bot_t_skin
			
			data.pos = getSpawnPosition(data.tId)
			#giving unique integer name
			data.name = String(69 + game_server.bot_settings.index)
			game_server.bot_settings.index += 1
			createUnit(data)
			result = true
			break
	
	if not result:
		print_debug("unable to add bot no profile available")


func S_removeUnit(uid : String):
	if get_tree().is_network_server():
		rpc("P_removeUnit", uid)
	else:
		Logger.LogError("S_removeUnit", "Not network server")


#Remove unit from game, client side
remotesync func P_removeUnit(uid : String):
	var unit = get_node(uid)
	if unit:
		assert(unit.is_in_group("Unit"), "Tried to remove non unit node")
		if unit.is_in_group("Bot"):
			#deactivate bot profile
			for i in game_states.bot_profiles.bot:
				if i.bot_name == unit.pname:
					i.is_in_use = false
					break
			
			emit_signal("bot_removed", unit)
		else:
			emit_signal("player_removed", unit)
		
		game_server._unit_data_list.erase(uid)
		unit.queue_free()


#Kick/remove all the bots from game
func removeAllBot():
	assert(get_tree().is_network_server(),"Not server")
	#get all bots
	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		S_removeUnit(i.name)


func _on_disconnected():
	MenuManager.changeScene("summary")
	queue_free()


#restart level, server side 
func S_restartLevel():
	assert(get_tree().is_network_server(),"Not server")
	rpc("P_restartLevel")
	yield(get_tree(), "idle_frame")
	createBots()

#restart level, client side
remotesync func P_restartLevel():
	var units = get_tree().get_nodes_in_group("Unit")
	for i in units:
		i.queue_free()

	#reset bot profile
	for i in game_states.bot_profiles.bot:
		i.is_in_use = false
	
	#reset data
	game_server.resetUnitData()
	team1.reset()
	team2.reset()
	spawned_units_ids.clear()
	$CanvasLayer.add_child(teamSelector)
