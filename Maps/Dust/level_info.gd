extends Node

var gameMode_dict = {
	name = "null",
	node_path = "",
	desc = ""
}

var level_name = "Dust"
var level_desc = "Medium sized map located in a desert"
var level_path = "res://Maps/Dust/Dust.tscn"
var icon : Texture = preload("res://Maps/Dust/minimap.png")
var gameModes = Array()


func _init():
	setupGameModes()


func setupGameModes():
	var dict = gameMode_dict.duplicate(true)
	dict.name = "Bombing"
	dict.node_path = "res://Maps/Dust/Bombing.tscn"
	gameModes.append(dict)
	
	dict = gameMode_dict.duplicate(true)
	dict.name = "FFA"
	dict.node_path = "res://Maps/Dust/TDM.tscn"
	gameModes.append(dict)
	

func getGameModeNodePath() -> String:
	for i in gameModes:
		if i.name == game_server.serverInfo.game_mode:
			return i.node_path
	return ""
