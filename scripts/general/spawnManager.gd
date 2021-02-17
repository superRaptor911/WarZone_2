extends Node

var player_scene = preload("res://objects/characters/player/Player.tscn")
onready var level_node = get_tree().get_nodes_in_group("Levels")[0] 

func _ready():
	name = "SpawnManager"


func spawnOurPlayer(team_id : int):
	rpc_id(1, "S_createPlayer", get_tree().get_network_unique_id(), team_id)



func createPlayer(id : int, team_id : int):
	if level_node.has_node(String(id)):
		print("SpawnManager::Error::Player %d already exists" % [id])
		return
	var player = player_scene.instance()
	player.name = String(id)
	level_node.add_child(player)
	player.set_network_master(id)
	findTeam(team_id).addPlayer(player)


func findTeam(team_id):
	var teams = get_tree().get_nodes_in_group("Teams")
	for i in teams:
		if i.team_id == team_id:
			return i
	return null


# Networking

func query_spawnedPlayerList():
	print("SpawnManager::Getting spawned players from the server")
	rpc_id(1, "S_spawnedPlayerList", get_tree().get_network_unique_id())


remote func S_spawnedPlayerList(peer_id : int):
	rpc_id(peer_id, "C_spawnedPlayerList", get_tree().get_nodes_in_group("Units"))


remote func C_spawnedPlayerList(list : Array):
	print("SpawnManager::Got %d players to spawn" % [list.size()])


remotesync func S_createPlayer(peer_id : int, team_id : int):
	rpc("C_createPlayer", peer_id, team_id)


remotesync func C_createPlayer(peer_id : int, team_id : int):
	createPlayer(peer_id, team_id)


