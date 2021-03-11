# Script to create/spawn/re-spawn players
extends Node

onready var level_node = get_tree().get_nodes_in_group("Levels")[0] 

func _ready():
	name = "SpawnManager"
	_connectSignals()


func _connectSignals():
	var network = get_tree().root.get_node("NetworkManager")
	network.connect("client_disconnected", self, "_on_player_disconnected")


func spawnOurPlayer(team_id : int):
	rpc_id(1, "S_createPlayer", get_tree().get_network_unique_id(), team_id)


func createPlayer(id : int, team_id : int, extra_data = null):
	var resource = get_tree().root.get_node("Resources")
	if level_node.has_node(String(id)):
		print("SpawnManager::Error::Player %d already exists" % [id])
		return
	var player = resource.entities.unit.instance()
	player.name = String(id)
	player.set_network_master(id)
	player.nick = get_tree().root.get_node("NetworkManager").player_register[id].nick
	level_node.add_child(player)
	findTeam(team_id).addPlayer(player)
	player.teleport(getSpawnPosition(team_id))
	var skin_id = randi() % resource.skins[team_id].size()
	player.setSkin(resource.skins[team_id][skin_id])
	if extra_data:
		player.health = extra_data.hp
		player.armour = extra_data.ap
		player.rotation = extra_data.rot
		player.position = extra_data.pos
		if extra_data.cur_gun == extra_data.gun1: 
			player.equipGun(extra_data.gun2)
			player.equipGun(extra_data.gun1)
		else:
			player.equipGun(extra_data.gun1)
			player.equipGun(extra_data.gun2)
	# Give default gun
	else:
		player.equipGun("glock18")


func getSpawnPosition(team_id : int):
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	var our_spawn_points = []
	for i in spawn_points:
		if i.team_id == team_id:
			our_spawn_points.append(i)
	if our_spawn_points.size() == 0:
		print("SpawnManager::Error::No spawn point for %d" % [team_id])
		print("SpawnManager::Spawning at (0, 0)")
		return Vector2(0, 0)
	return our_spawn_points[randi() % our_spawn_points.size()].position


func findTeam(team_id):
	var teams = get_tree().get_nodes_in_group("Teams")
	for i in teams:
		if i.team_id == team_id:
			return i
	return null


func _on_player_disconnected(id : int):
	var level = get_tree().get_nodes_in_group("Levels")[0]
	var player = level.get_node(String(id))
	if !player:
		print("SpawnManager::Error::player %d not found" % [id])
	player.queue_free()
	print("SpawnManager::Des-spawning player " + String(id))


# Networking
remotesync func S_createPlayer(peer_id : int, team_id : int):
	rpc("C_createPlayer", peer_id, team_id)


remotesync func C_createPlayer(peer_id : int, team_id : int):
	createPlayer(peer_id, team_id)


