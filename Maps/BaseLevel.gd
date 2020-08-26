extends Node2D

signal player_created(player)
signal player_removed(player)

signal bot_created(bot)
signal bot_removed(bot)

export var Level_Name = "no_name"
export var capture_mod = false
# author , INC = "preinstalled"
export var author = "INC"


var team1 = preload("res://Objects/scripts/Team.gd").new(0,self)
var team2 = preload("res://Objects/scripts/Team.gd").new(1,self)

var teamSelector = null
var spec_mode = preload("res://Objects/Game_modes/Spectate.tscn").instance()
var dropedItem_manager = preload("res://Objects/Misc/DropedItemManager.tscn").instance()

var spawned_units = Array()
var spawn_points = Array()

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
	
	if not game_states.game_settings.shadows:
		$BaseMap/shadow.hide()
		
	game_server.resetUnitData()
		
	#setup teams
	add_child(team1)
	add_child(team2)
	add_child(dropedItem_manager)
	
	game_server._unit_data_list.clear()
	spawn_points = get_tree().get_nodes_in_group("SpawnPoint")
	network.connect("disconnected", self, "_on_disconnected")
	loadGameMode()
	
	#handle team selector
	add_child(teamSelector)
	teamSelector.connect("team_selected",self,"_on_player_selected_team")
	teamSelector.connect("spectate_mode",self,"_on_specmode_selected")
	spec_mode.connect("leave_spec_mode",self,"_on_spec_mode_leave")
	
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")
		genNavigation()
	else:
		rpc_id(1,"S_getExistingUnits", String(game_states.player_info.net_id))

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
	if game_server.serverInfo.game_mode == "Zombie Mod":
		game_mode = load("res://Objects/Game_modes/ZombieMod/ZombieMod.tscn").instance()
	elif game_server.serverInfo.game_mode == "TDM":
		game_mode = load("res://Objects/Game_modes/TDM/TDM.tscn").instance()
	elif game_server.serverInfo.game_mode == "Bombing":
		game_mode = load("res://Objects/Game_modes/BombDiffuse.tscn").instance()
	
	#add game mode
	if game_mode:
		game_mode.add_to_group("GameMode")
		add_child(game_mode)
		
		#Use custom team selector, if exist
		var ts = game_mode.get("Custom_teamSelector")
		
		if ts:
			teamSelector = load(ts).instance()
			Logger.Log("Using custom team selector from %s" % [ts])
		#switch to default team selector
		else:
			teamSelector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
	
	else:
		teamSelector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
		Logger.LogError("loadGameMode", "Unable to load game mode")


func _on_specmode_selected():
	Logger.Log("[%s] selected spectate" % [game_states.player_info.name])
	add_child(spec_mode)
	remove_child(teamSelector)

func _on_spec_mode_leave():
	remove_child(spec_mode)
	add_child(teamSelector)

func _on_player_selected_team(selected_team):
	rpc_id(1,"S_createPlayer",game_states.player_info,selected_team)
	remove_child(teamSelector)

#When a player disconnects
func _on_player_removed(pinfo):
	S_removeUnit(String(pinfo.net_id))


func getSpawnPosition(team_id : int) -> Vector2:
	if spawn_points.empty():
		print("Error : No spawn points available")
	else:
		var best_spawn_point = null
		var min_value = 999
		
		for i in spawn_points:
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
		unit.gun_1.clip_count = 999
		unit.gun_2.clip_count = 999



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
	#createBots()

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
	add_child(teamSelector)


remotesync func S_changeUnitTeam(unit_id : String, team_id : int):
	if get_tree().is_network_server():
		var unit = game_server._unit_data_list.get(unit_id)
		if not unit:
			Logger.LogError("S_changeUnitTeam", "Unit with id %s not found" % [unit_id])
			return
		
		if unit.ref.team.team_id == team_id:
			Logger.Log("Failed to change team. Already in team %d" % [team_id])
			return
		
		unit.ref.killChar()
		rpc("P_changeUnitTeam", unit_id, team_id)


remotesync func P_changeUnitTeam(unit_id : String, team_id : int):
		var unit = game_server._unit_data_list.get(unit_id)
		if not unit:
			Logger.LogError("S_changeUnitTeam", "Unit with id %s not found" % [unit_id])
			return
		
		#remove from current team
		unit.ref.team.removePlayer(unit.ref)
		
		#Add to new team
		if team1.team_id == team_id:
			team1.addPlayer(unit.ref)
		else:
			team2.addPlayer(unit.ref)
		
		#assign skin
		if unit.ref.is_in_group("Bot"):
			#Terrorist Team
			if team_id == 0:
				unit.ref.get_node("Model").setSkin("t1")
			#CT team
			else:
				unit.ref.get_node("Model").setSkin("ct1")
		#Get custom skins for Player
		else:
			var data = network.players.get(int(unit.ref.name))
			#Terrorist Team
			if team_id == 0:
				unit.ref.get_node("Model").setSkin(data.t_model)
			#CT team
			else:
				unit.ref.get_node("Model").setSkin(data.ct_model)


################################################################################


# Reference to a new AStar navigation grid node
onready var astar = AStar.new()

# Used to find the centre of a tile
onready var half_cell_size = Vector2(32,32)

# All tiles that can be used for pathfinding
onready var traversable_Tiles = $BaseMap.get_used_cells()

# The bounds of the rectangle containing all used tiles on this tilemap
onready var used_rect = $BaseMap.get_used_rect()

onready var map = $BaseMap


func genNavigation():
	# Add all tiles to the navigation grid
	_add_traversable_tiles(traversable_Tiles)

	# Connects all added tiles
	_connect_traversable_tiles(traversable_Tiles)


## Private functions


# Adds tiles to the A* grid but does not connect them
# ie. They will exist on the grid, but you cannot find a path yet
func _add_traversable_tiles(traversable_tiles):

	# Loop over all tiles
	for tile in traversable_tiles:

		# Determine the ID of the tile
		var id = _get_id_for_point(tile)

		# Add the tile to the AStar navigation
		# NOTE: We use Vector3 as AStar is, internally, 3D. We just don't use Z.
		astar.add_point(id, Vector3(tile.x, tile.y, 0))


# Connects all tiles on the A* grid with their surrounding tiles
func _connect_traversable_tiles(traversable_tiles):

	# Loop over all tiles
	for tile in traversable_tiles:

		# Determine the ID of the tile
		var id = _get_id_for_point(tile)

		# Loops used to search around player (range(3) returns 0, 1, and 2)
		for x in range(3):
			for y in range(3):

				# Determines target, converting range variable to -1, 0, and 1
				var target = tile + Vector2(x - 1, y - 1)

				# Determines target ID
				var target_id = _get_id_for_point(target)

				# Do not connect if point is same or point does not exist on astar
				if tile == target or not astar.has_point(target_id):
					continue

				# Connect points
				astar.connect_points(id, target_id, true)


# Determines a unique ID for a given point on the map
func _get_id_for_point(point):

	# Offset position of tile with the bounds of the tilemap
	# This prevents ID's of less than 0, if points are behind (0, 0)
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y

	# Returns the unique ID for the point on the map
	return x + y * used_rect.size.x


## Public functions

# Returns a path from start to end
# These are real positions, not cell coordinates
func getPath(start, end) -> PoolVector2Array:

	# Convert positions to cell coordinates
	var start_tile = map.world_to_map(start)
	var end_tile = map.world_to_map(end)

	# Determines IDs
	var start_id = _get_id_for_point(start_tile)
	var end_id = _get_id_for_point(end_tile)

	# Return null if navigation is impossible
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return PoolVector2Array()

	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)

	# Convert Vector3 array (remember, AStar is 3D) to real world points
	var path_world = []
	for point in path_map:
		var point_world = map.map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	return path_world


func getNearestPoint(pos : Vector2) -> Vector2:
	var min_d = 99999999
	var point = Vector2(0,0)
	for i in traversable_Tiles:
		var d = ((i*64) - pos).length_squared()
		if d < min_d:
			min_d = d
			point = i*64 + Vector2(32,32)
	
	return point
