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
				"Bombing", "res://Maps/Dust/Bombing.tscn" ,
				"FFA","res://Maps/Dust/TDM.tscn"
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
