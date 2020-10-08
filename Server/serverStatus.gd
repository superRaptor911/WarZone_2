extends Control

var levels : Array

var mode_settings = {
	TDM = {
		time_limit = 5,
		max_score = 50
	},
	
	Elimination = {
		round_time = 2, # Round time limit in minutes
		max_rounds = 2, # Maximum rounds in 1 half
	},
	
	CheckPoints = {
		round_time = 8, # Round time limit in minutes
		max_score = 500,
		respawn_time = 8
	}
}


func _ready():
	var lvl_dat_file = load("res://Maps/level_info.gd").new()
	levels = lvl_dat_file.levels.values()
	fillData()


func fillData():
	var level_list = $cur_level
	var mode_list = $cur_gamemode
	var id_lvl = 0
	
	print("current game mode ", game_server.serverInfo)
	# Fill list
	for i in levels:
		level_list.add_item(i.name)
		if i.name == game_server.serverInfo.map:
			level_list.select(id_lvl)
			
			var modes_count = i.game_modes.size() / 2
			var id_mode = 0
			for j in modes_count:
				mode_list.add_item(i.game_modes[j * 2])
				if i.game_modes[j * 2] == game_server.serverInfo.game_mode:
					mode_list.select(id_mode)
				id_mode += 1
		id_lvl += 1


func _on_back_pressed():
	pass # Replace with function body.


func _on_reload_pressed():
	var id = $cur_level.get_selected_id()
	var lvl = $cur_level.get_item_text(id)
	id = $cur_gamemode.get_selected_id()
	var mode = $cur_gamemode.get_item_text(id)
	game_server.rpc("P_changeLevelTo", lvl, mode)


func _on_edit_pressed():
	$console.visible = !$console.visible


func _on_console_text_entered(new_text):
	$console.clear()
	$console/Label.text += "\n-> " + new_text


func parseConsole(text : String):
	var strings = text.split(" ")
	var string_count = strings.size()
	
	match strings[0]:
		"list_players": 
			pass


func list_players(no_bots = false, no_players = false):
	for i in game_server._unit_data_list:
		pass
