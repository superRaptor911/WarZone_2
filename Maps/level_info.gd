extends Node

var template = {
		name = "Dust II",
		minimap = "",
		game_modes = [
				{bombing = "" },
				{FFA = ""}
			],
		desc = "",
		debug = false
	}


var levels = {
	
	l1 = {
		name = "Dust II",
		icon = preload("res://Maps/Dust/minimap.png"),
		game_modes = [
				"Zombie Mod", "res://Maps/Dust/Zm_Dust.tscn",
				"Bombing", "res://Maps/Dust/Bombing.tscn" ,
				"TDM","res://Maps/Dust/TDM.tscn"
			],
		desc = "",
		debug = false
	},
	
	l2 = {
		name = "Test map",
		icon = preload("res://Maps/WpnTest/minimap.png"),
		game_modes = [
				"Test", "res://Maps/WpnTest/TestingMode.tscn"
			],
		desc = "Test Map!!!",
		debug  = true
	}
}


func getLevelInfo(level_name) -> Dictionary:
	var vals = levels.values()
	for i in vals:
		if i.name == level_name:
			return i
	
	return {}


func getLevelGameModePath(level : Dictionary, game_mode : String) -> String:
	var i = 0
	var sz = level.game_modes.size()
	while (i < sz):
		if level.game_modes[i] == game_mode:
			return level.game_modes[i + 1]
		i += 2
	
	return ""

