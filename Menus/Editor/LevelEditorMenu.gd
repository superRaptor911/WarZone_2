extends Control

func _ready():
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_mapEditor_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LEM/LevelEditor")


func _on_gameMode_pressed():
	var file = File.new()
	var file_name = "user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn"
	
	if file.file_exists(file_name):
		MusicMan.click()
		MenuManager.changeScene("EMS/LEM/GameModesMenu")
	else:
		Logger.notice.showNotice(self, "Error", "You need to create a level first.", Color.red)



func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("EditorMapSelector")


func _on_convert_pressed():
	var levelInfo = {
		name = "Dust II",
		icon = "",
		game_modes = [

			],
		desc = "",
		debug = false
	}
	
	var base_map = null
	var game_modes = [null, null]
	var map_name = game_server.serverInfo.map
	
	var file = File.new()
	var file_name = "user://custom_maps/maps/" + map_name + ".tscn"
	if file.file_exists(file_name):
		base_map = load(file_name).instance()
		base_map.name = "BaseMap"
		base_map.force_update = false
	else:
		base_map.queue_free()
		Logger.notice.showNotice(self, "Failed", 
		"Map not Found. Create Map by pressing MAP EDITOR.", Color.red)
		return
	# TDM
	file_name = "user://custom_maps/gameModes/TDM/" + map_name + ".tscn"
	if file.file_exists(file_name):
		var final_level = Node.new()
		var level_node = Node2D.new()
		level_node.add_to_group("Level", true)
		level_node.set_script(load("res://Maps/BaseLevel.gd"))
		final_level.add_child(level_node)
		level_node.owner = final_level
		level_node.add_child(base_map)
		base_map.owner = final_level
		game_modes[0] = load(file_name).instance()
		final_level.add_child(game_modes[0])
		game_modes[0].owner = final_level
		# Save scene
		var packed_scene = PackedScene.new()
		var result = packed_scene.pack(final_level)
		var save_path = "user://custom_maps/levels/TDM_" + game_server.serverInfo.map + ".tscn"
		if result == OK:
			ResourceSaver.save(save_path, packed_scene)
		# Free resources
		level_node.remove_child(base_map)
		final_level.remove_child(game_modes[0])
		final_level.queue_free()
	# Zombie Mod
	file_name = "user://custom_maps/gameModes/Zombie/" + map_name + ".tscn"
	if file.file_exists(file_name):
		var final_level = Node.new()
		var level_node = Node2D.new()
		level_node.set_script(load("res://Maps/BaseLevel.gd"))
		level_node.add_to_group("Level", true)
		final_level.add_child(level_node)
		level_node.owner = final_level
		level_node.add_child(base_map)
		base_map.owner = final_level
		game_modes[1] = load(file_name).instance()
		final_level.add_child(game_modes[1])
		game_modes[1].owner = final_level
		# Save scene
		var packed_scene = PackedScene.new()
		var result = packed_scene.pack(final_level)
		var save_path = "user://custom_maps/levels/ZM_" + game_server.serverInfo.map + ".tscn"
		if result == OK:
			ResourceSaver.save(save_path, packed_scene)
		# Free resources
		level_node.remove_child(base_map)
		final_level.remove_child(game_modes[1])
		final_level.queue_free()
	
	# Write config
	levelInfo.name = game_server.serverInfo.map
	levelInfo.icon= "user://custom_maps/minimaps/" + game_server.serverInfo.map + ".png"
	
	var counter = false
	
	if game_modes[0]:
		levelInfo.game_modes.append("TDM")
		levelInfo.game_modes.append("user://custom_maps/levels/TDM_" + game_server.serverInfo.map + ".tscn")
		game_modes[0].queue_free()
		counter = true
	
	if game_modes[1]:
		levelInfo.game_modes.append("Zombie Mod")
		levelInfo.game_modes.append("user://custom_maps/levels/ZM_" + game_server.serverInfo.map + ".tscn")
		game_modes[1].queue_free()
		counter = true
	
	base_map.queue_free()
	if (not counter):
		Logger.notice.showNotice(self, "Failed", 
		"Game Mode not found. Create a Game Mode by pressing GAME MODE EDITOR.", Color.red)
		return
	var save_path = "user://custom_maps/" + game_server.serverInfo.map + ".dat"
	game_states.save_data(save_path, levelInfo, false)
