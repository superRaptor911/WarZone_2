extends Node

var player_scene = preload("res://objects/characters/player/Player.tscn")
var level_node	 = null

func _ready():
	name = "SpawnManager"
	level_node = get_tree().get_nodes_in_group("Levels")[0]


func spawnPlayer(id : String):
	if level_node.node_exists(id):
		print("SpawnManager::Error::Player %s already exists" % [id])
		return
	var player = player_scene.instance()
	player.name = id
	level_node.add_child(player)


