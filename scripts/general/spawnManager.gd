extends Node

var player_scene = preload("res://objects/characters/player/Player.tscn")
var level_node	 = null

onready var level_manager = get_tree().root.get_node("LevelManager")

func _ready():
	name = "SpawnManager"
	level_manager.connect("level_loaded", self, "_on_level_loaded")


func spawnPlayer(id : int):
	if level_node.node_exists(String(id)):
		print("SpawnManager::Error::Player %d already exists" % [id])
		return
	var player = player_scene.instance()
	player.name = String(id)
	level_node.add_child(player)
	player.set_network_master(id)


func _on_level_loaded():
	level_node = get_tree().get_nodes_in_group("Levels")[0]



# Networking

func query_spawnedPlayerList():
	print("SpawnManager::Getting spawned players from the server")
	rpc_id(1, "S_spawnedPlayerList", get_tree().get_network_unique_id())


remote func S_spawnedPlayerList(peer_id : int):
	rpc_id(peer_id, "C_spawnedPlayerList", get_tree().get_nodes_in_group("Units"))


remote func C_spawnedPlayerList(list : Array):
	print("SpawnManager::Got %d players to spawn" % [list.size()])



