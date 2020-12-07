extends Node

var levels = {
	l4 = {
			debug = false, 
			desc = "Community map made by an user. Small map, Ideal for close combat",
			game_modes = [
							"Elimination", "res://Maps/AIM-MAP/levels/ELIM_AIM-MAP.tscn",
							"TDM", "res://Maps/AIM-MAP/levels/TDM_AIM-MAP.tscn",
							"Zombie Mod", "res://Maps/AIM-MAP/levels/Zombie_AIM-MAP.tscn"
						 ],
			icon = preload("res://Maps/AIM-MAP/minimaps/AIM-MAP.png"),
			name = "AIM-MAP"
		},

	l5 = {
		debug = false,
		desc = "",
		game_modes = [
						"CheckPoints", "res://Maps/Minecraft dungeons/levels/CP_MINECRAFT_DUNGEONS.tscn",
						"Elimination", "res://Maps/Minecraft dungeons/levels/ELIM_MINECRAFT.tscn",
						"TDM", "res://Maps/Minecraft dungeons/levels/TDM_Minecraft dungeons.tscn",
						"Zombie Mod", "res://Maps/Minecraft dungeons/levels/Zombie_Minecraft dungeons.tscn"
					],
		icon  = preload("res://Maps/Minecraft dungeons/minimaps/Minecraft dungeons.png"),
		name = "Minecraft dungeons"
	},
	
	l6 = {
		debug = false,
		desc = "",
		game_modes = [
						"Elimination", "res://Maps/the center of house/levels/ELIM_CENTRE_OF_HOUSE.tscn",
						"TDM", "res://Maps/the center of house/levels/TDM_the center of house.tscn"
					 ],
		icon = preload("res://Maps/the center of house/minimaps/the center of house.png"),
		name = "the center of house"
	},


	l3 = {
		name = "fy Dust",
		icon = preload("res://Maps/fy_dust/minimap.png"),
		game_modes = [
				"Zombie Mod", "res://Maps/fy_dust/zm_fy_dust.tscn",
				"TDM", "res://Maps/fy_dust/fy_dust_tdm.tscn"
			],
		desc = "Standard Map",
		debug = false
	},
	
	l1 = {
		name = "Dust II",
		icon = preload("res://Maps/Dust/minimap.png"),
		game_modes = [
				"Zombie Mod", "res://Maps/Dust/Zm_Dust.tscn",
				"CheckPoints", "res://Maps/Dust/CheckPointsDUST.tscn",
				"Elimination", "res://Maps/Dust/DustComp.tscn",
				"TDM","res://Maps/Dust/TDM.tscn"
			],
		desc = "Standard Map Inspired by dust 2.",
		debug = false
	},
	
	l2 = {
		name = "Test map",
		icon = preload("res://Maps/WpnTest/minimap.png"),
		game_modes = [
				"TDM", "res://Maps/WpnTest/TestingMode.tscn"
			],
		desc = "Test Map!!!",
		debug  = true
	},

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

