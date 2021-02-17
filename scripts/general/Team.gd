extends Node

var team_id : int      = 0
var team_name : String = ""

# a player has { name, id, score, kills, deaths }

var players = {}


func _ready():
	pass


func _connectSignals():
	var network = get_tree().root.get_node("Network")
	network.connect("client_disconnected", self, "_on_client_disconnected")


func addPlayer(player_ref):
	player_ref.team_id = team_id
	player_ref.connect("entity_killed", self,"on_player_killed")
	player_ref.connect("entity_fraged", self,"on_player_fraged")
	players[player_ref.name] = {
			name   = player_ref.name,
			nick   = player_ref.nick,
			score  = 0,
			kills  = 0,
			deaths = 0,
			ping   = 0
		}


func _on_client_disconnected(id : int):
	if players.has(String(id)):
		players.erase((id))
		print("Team::Removing Player %d from Team %s" % [id, team_name])


func on_player_killed(victim_name, _killer_name, _weapon_name):
	var player = findPlayer(victim_name)
	# Error check
	if !player:
		print("Team::Fatal_Error unable to find player " + victim_name )
		return
	# Increment Death count
	player.deaths += 1


func on_player_fraged(killer_name, _victim_name,_weapon_name):
	var player = findPlayer(killer_name)
	# Error check
	if !player:
		print("Team::Fatal_Error unable to find player " + killer_name)
		return
	# Increment Death count
	player.kills += 1


func findPlayer(player_name):
	if player_name == "":
		return null
	var player = players.get(player_name)
	if player:
		return player
	print("player::Failed to find player " + player_name)
	return null

