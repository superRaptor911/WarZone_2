extends Node

var gameMode_dict = {
	name = "null",
	node_path = "",
	desc = ""
}

var level_name = "DesertComplex"
var level_desc = "Test map for testing WarZone 2. Created for testing purposes only"
var level_path = "res://Maps/DesertComplex/DesertComplex.tscn"
var icon : Texture = preload("res://Maps/DesertComplex/minimap.png")
var gameModes = Array()


func _init():
	setupGameModes()


func setupGameModes():
	var dict = gameMode_dict.duplicate(true)
	dict.name = "FFA"
	dict.node_path = "res://Maps/DesertComplex/TDM.tscn"
	gameModes.append(dict)


func getGameModeNodePath() -> String:
	for i in gameModes:
		if i.name == game_server.serverInfo.game_mode:
			return i.node_path
	return ""
