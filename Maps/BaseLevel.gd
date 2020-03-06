extends Node2D

export var Level_Name = "no_name"

export var team1_name = "A"
var team1 = preload("res://Objects/scripts/Team.gd").new("A")
export var team2_name = "B"
var team2 = preload("res://Objects/scripts/Team.gd").new("B")

var teamSelector = preload("res://Menus/Lobby/TeamSelect.tscn").instance()

var _game
var max_spawn_pts = 0

#character data dictionary for holding spawn information 
var char_data_dict = {
	pname = "player",
	name = "null",
	team_id = "A",
	pos = Vector2(0,0),
	g1 = "",
	g2 = ""
}

func _ready():
	game_server._player_data_list.clear()
	max_spawn_pts = $spawn.get_child_count()
	#add_child(load("res://Maps/" + game_states.CURRENT_LEVEL + ".tscn").instance())
	network.connect("player_list_changed", self, "_on_player_list_changed")
	network.connect("disconnected", self, "_on_disconnected")
	add_child(teamSelector)
	teamSelector.connect("teamSelected",self,"_on_player_selected_team")
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")

func _on_player_selected_team(selected_team):
	_init_game()
	if not get_tree().is_network_server():
		rpc_id(1,"serverGetPlayers", game_states.player_info.net_id)
		
	rpc("spawn_player", game_states.player_info, randi() % max_spawn_pts, selected_team)
	teamSelector.queue_free()
	

func _on_player_removed(pinfo):
	despawn_player(pinfo)


var arr = Array()

#get 
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
		char_data_list.append(char_data)
	#send data to peer
	rpc_id(peer_id,"peerSpawnPlayers", char_data_list)


remote func peerSpawnPlayers(player_dict):
	for i in player_dict:
		spawnPlayer(i)

#spawn an individual player
func spawnPlayer(char_data):
	if arr.has(int(char_data.name)):
		print("Fatal network spawn error")
		return
	var nactor = game_states.classResource.player.instance()
	nactor.position = char_data.pos
	nactor.set_name(char_data.name)
	nactor.load_guns(char_data.g1, char_data.g2)
	nactor.pname = char_data.pname
	nactor.id = int(char_data.name)
	nactor.set_name(char_data.name)
	
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (int(char_data.name) != 1):
		nactor.set_network_master(int(char_data.name))
		game_server.addPlayer(char_data.pname, int(char_data.name), char_data.team_id)
		arr.push_back(int(char_data.name))
	else:
		game_server.addPlayer(char_data.pname, 1, char_data.team_id)
		arr.push_back(1)
	
	#assign player a team
	if char_data.team_id == "A":
		team1.addPlayer(nactor)
	elif char_data.team_id == "B":
		team2.addPlayer(nactor)
	else:
		print("Fatal Error: invalid team id for player ", char_data.pname)
	add_child(nactor)


remotesync func spawn_player(pinfo, spawn_index, team):
	if (spawn_index == -1):
		spawn_index = network.players.size()
	
	if arr.has(pinfo.net_id):
		print("Fatal network spawn error")
		return
	arr.push_back(pinfo.net_id)
	
	var nactor = game_states.classResource.player.instance()
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")[0].get_children()
	nactor.position = spawn_points[spawn_index].position
	nactor.load_guns(pinfo.primary_gun_name,pinfo.sec_gun_name)
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))
	
	nactor.pname = pinfo.name
	nactor.id = pinfo.net_id
	game_server.addPlayer(pinfo.name, pinfo.net_id,team)
	if team == "A":
		team1.addPlayer(nactor)
	elif team == "B":
		team2.addPlayer(nactor)
	add_child(nactor)



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
	player_node.queue_free()
	
func _on_disconnected():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")
	queue_free()


func _init_game():
	game_server.init_scoreBoard()
	var game_mode = null
	#load appropriate game mode
	if game_server.serverInfo.game_mode == "SURVIVAL":
		game_mode = load("res://Objects/Game_modes/SURVIVAL_mode.tscn").instance()
	elif game_server.serverInfo.game_mode == "FFA":
		game_mode = load("res://Objects/Game_modes/FFA_mode.tscn").instance()
	#add game mode
	if game_mode:
		game_mode.add_to_group("GameMode")
		add_child(game_mode)
