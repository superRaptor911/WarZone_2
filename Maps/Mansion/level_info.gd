extends Node

var gameMode_dict = {
	name = "null",
	node_path = "",
	desc = ""
}

var level_name = "Mansion"
var level_desc = "Small map"
var level_path = "res://Maps/Mansion/Mansion.tscn"
var icon : Texture = preload("res://Maps/Mansion/minimap.png")
var gameModes = Array()


func _init():
	setupGameModes()


func setupGameModes():
	var dict = gameMode_dict.duplicate(true)
	dict.name = "FFA"
	dict.node_path = "res://Maps/Mansion/FFA.tscn"
	gameModes.append(dict)
	



func getGameModeNodePath() -> String:
	for i in gameModes:
		if i.name == game_server.serverInfo.game_mode:
			return i.node_path
	return ""
