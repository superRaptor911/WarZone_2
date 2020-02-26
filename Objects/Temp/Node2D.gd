extends Node2D

export var Level_Name = "no_name"

export var team1_name = "A"
var team1 = preload("res://Objects/scripts/Team.gd").new()
export var team2_name = "B"
var team2 = preload("res://Objects/scripts/Team.gd").new()

var _game

#counts number of players spawned
#no_players_spwaned should be same as nuber of players
#in player table
var no_players_spwaned = 0

func _ready():
	add_child(team1)
	add_child(team2)
	#add_child(load("res://Maps/" + game_states.CURRENT_LEVEL + ".tscn").instance())
	network.connect("player_list_changed", self, "_on_player_list_changed")
	network.connect("disconnected", self, "_on_disconnected")
	if (get_tree().is_network_server()):
		spawn_players(game_states.player_info, 1)
	else:
		rpc_id(1, "spawn_players", game_states.player_info, -1)
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")


func _on_player_removed(pinfo):
	despawn_player(pinfo)


var arr = Array()

remote func spawn_players(pinfo, spawn_index):
	if (spawn_index == -1):
		spawn_index = network.players.size()
	
	if (get_tree().is_network_server() && pinfo.net_id != 1):
		var s_index = 1      # Will be used as spawn index
		for id in network.players:
			if (id != pinfo.net_id):
				rpc_id(pinfo.net_id, "spawn_players", network.players[id], s_index)
			
			if (id != 1):
				rpc_id(id, "spawn_players", pinfo, spawn_index)
			
			s_index += 1
	if arr.has(pinfo.net_id):
		return
	arr.push_back(pinfo.net_id)
	var nactor = game_states.classResource.player.instance()
	var spawn_points
	for sp in get_tree().get_nodes_in_group("spawn_points"):
		spawn_points = sp.get_children()
		
	nactor.position = spawn_points[spawn_index].position
	nactor.load_guns(pinfo.primary_gun_name,pinfo.sec_gun_name)
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
		nactor.set_name(str(pinfo.net_id))
	
	nactor.pname = pinfo.name
	team1.addPlayer(nactor)
	print("spawned ",nactor.pname)
	add_child(nactor)
	no_players_spwaned += 1
	if no_players_spwaned == network.players.size():
		_init_game()



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
	if game_states.GAME_MODE == game_states.GAME_MODES.SURVIVAL:
		var mode = load("res://Objects/Game_modes/SURVIVAL_mode.tscn")
		add_child(mode.instance())
	elif game_states.GAME_MODE == game_states.GAME_MODES.FFA:
		var mode = load("res://Objects/Game_modes/FFA_mode.tscn")
		add_child(mode.instance())
