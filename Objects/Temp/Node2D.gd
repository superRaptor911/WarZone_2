extends Node2D

export var Level_Name = "no_name"

export var team1_name = "A"
var team1 = preload("res://Objects/scripts/Team.gd").new("A")
export var team2_name = "B"
var team2 = preload("res://Objects/scripts/Team.gd").new("B")

var teamSelector = preload("res://Menus/Lobby/TeamSelect.tscn").instance()

var _game
var max_spawn_pts = 0

#counts number of players spawned
#no_players_spwaned should be same as nuber of players
#in player table
var no_players_spwaned = 0

func _ready():
	max_spawn_pts = $spawn.get_child_count()
	#add_child(load("res://Maps/" + game_states.CURRENT_LEVEL + ".tscn").instance())
	network.connect("player_list_changed", self, "_on_player_list_changed")
	network.connect("disconnected", self, "_on_disconnected")
	add_child(teamSelector)
	teamSelector.connect("teamSelected",self,"_on_player_selected_team")
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")


func _on_player_selected_team(selected_team):
	rpc("spawn_players", game_states.player_info, randi() % max_spawn_pts, selected_team)
	teamSelector.queue_free()
	_init_game()

func _on_player_removed(pinfo):
	despawn_player(pinfo)


var arr = Array()

remotesync func spawn_players(pinfo, spawn_index, team):
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
	
	print(team)
	print("spawned ",nactor.pname)
	add_child(nactor)
	no_players_spwaned += 1



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
