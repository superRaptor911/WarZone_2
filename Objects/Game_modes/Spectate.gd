extends Node

var players_n_bots = Array()
var current_spec_player = null
var spec_id = 0

var str_format = "%s\nKills : %d\nDeaths : %d\nHP : %d\nAP : %d"

signal leave_spec_mode

func _ready():
	players_n_bots.clear()
	getPlayersAndBots()
	
	var level_group = get_tree().get_nodes_in_group("Level")
	if not level_group.empty():
		var level = level_group[0]
		level.connect("player_spawned",self,"_on_player_spawned") 
		level.connect("player_despawned",self,"_on_player_despawned")
		var world_Size = level.get_node("BaseMap/height").get_used_rect().size
		$Minimap.rect_size = world_Size * 8

func getPlayersAndBots():
	players_n_bots = get_tree().get_nodes_in_group("User")
	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		players_n_bots.append(i)
	specRandomPlayer()


func _on_player_spawned(player):
	players_n_bots.append(player)

func _on_player_despawned(player):
	var was_current = (current_spec_player == player)
	players_n_bots.erase(player)
	if was_current:
		specRandomPlayer()

func specNextPlayer():
	var alive_players = Array()
	for i in players_n_bots:
		if i.alive:
			alive_players.append(i)
		
	if not alive_players.empty():
		spec_id += 1
		if spec_id >= alive_players.size():
			spec_id = 0
		 
		current_spec_player = alive_players[spec_id]
		current_spec_player.get_node("Camera2D").current = true
		$Minimap.local_player = current_spec_player
	else:
		current_spec_player = null

func specRandomPlayer():
	var alive_players = Array()
	for i in players_n_bots:
		if i.alive:
			alive_players.append(i)
		
	if not alive_players.empty():
		spec_id = randi() % alive_players.size()
		current_spec_player = alive_players[spec_id]
		current_spec_player.get_node("Camera2D").current = true
		$Minimap.local_player = current_spec_player
	else:
		current_spec_player = null


func _on_spec_pressed():
	specNextPlayer()


func _on_menu_pressed():
	if current_spec_player:
		current_spec_player.get_node("Camera2D").current = false
	emit_signal("leave_spec_mode")

func _process(delta):
	$Text/Label.text = str_format % [current_spec_player.pname, 
	current_spec_player.kills, current_spec_player.deaths, current_spec_player.HP,
	current_spec_player.AP]
