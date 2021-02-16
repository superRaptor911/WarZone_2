extends Node

var player_scene = preload("res://objects/characters/player/Player.tscn")
var level_node	 = null

func _ready():
	name = "SpawnManager"
	level_node = get_tree().get_nodes_in_group("Levels")[0]


func spawnPlayer(id : int):
	if level_node.node_exists(String(id)):
		print("SpawnManager::Error::Player %d already exists" % [id])
		return
	var player = player_scene.instance()
	player.name = String(id)
	level_node.add_child(player)


