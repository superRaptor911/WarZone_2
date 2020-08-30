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
		var notice  = Notice.new()
		notice.showNotice(self, "Error", "You need to create a level first.", Color.red)


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
		var notice = Notice.new()
		notice.showNotice(self, "Failed", 
		"Map not Found. Create Map by pressing MAP EDITOR.", Color.red)
		return
	
	# TDM MODE
	file_name = "user://custom_maps/gameModes/TDM/" + map_name + ".tscn"
	if file.file_exists(file_name):
		var final_level = Node.new()
		final_level.name = "TDM"
		var level_node = Node2D.new()
		level_node.name = "Level"
		level_node.set_script(load("res://Maps/BaseLevel.gd"))
		level_node.Level_Name = map_name
		level_node.author = String(OS.get_unique_id())
		level_node.add_to_group("Level", true)
		final_level.add_child(level_node)
		level_node.owner = final_level
		
		level_node.add_child(base_map)
		base_map.owner = final_level
		game_modes[0] = load(file_name).instance()
		game_modes[0].name = "GameMode"
		final_level.add_child(game_modes[0])
		game_modes[0].owner = final_level
		# Save scene
		var packed_scene = PackedScene.new()
		var result = packed_scene.pack(final_level)
		var save_path = "user://custom_maps/levels/TDM_" + map_name + ".tscn"
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
		final_level.name = "TDM"
		var level_node = Node2D.new()
		level_node.name = "Level"
		level_node.set_script(load("res://Maps/BaseLevel.gd"))
		level_node.Level_Name = map_name
		level_node.author = String(OS.get_unique_id())
		level_node.add_to_group("Level", true)
		final_level.add_child(level_node)
		level_node.owner = final_level
		
		level_node.add_child(base_map)
		base_map.owner = final_level
		game_modes[1] = load(file_name).instance()
		game_modes[1].name = "GameMode"
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
		var notice = Notice.new()
		notice.showNotice(self, "Failed", 
		"Game Mode not found. Create a Game Mode by pressing GAME MODE EDITOR.", Color.red)
		return
	var save_path = "user://custom_maps/" + game_server.serverInfo.map + ".dat"
	game_states.save_data(save_path, levelInfo, false)
	
	var notice = Notice.new()
	notice.showNotice(self, "Generated !", 
	"Your map was generated. You can now play your map in New Game", Color.white, Color.green)



func _on_more_pressed():
	UiAnim.animZoomOut([$PanelContainer])
	$PanelContainer2.show()
	UiAnim.animZoomIn([$PanelContainer2])


func _on_Delete_pressed():
	var dir = Directory.new()
	var map_name = game_server.serverInfo.map
	dir.remove("user://custom_maps/" + map_name + ".dat")
	dir.remove("user://custom_maps/gameModes/Zombie/" + map_name + ".tscn")
	dir.remove("user://custom_maps/gameModes/TDM/" + map_name + ".tscn")
	dir.remove("user://custom_maps/maps/" + map_name + ".tscn")
	
	var notice = Notice.new()
	notice.showNotice(self, "Done !", "Your map was deleted")
	notice.connect("notice_closed", self, "on_delete_notice_Closed")



func on_delete_notice_Closed():
	MenuManager.changeScene("EditorMapSelector")


func _on_More_back_pressed():
	$PanelContainer.show()
	UiAnim.animZoomIn([$PanelContainer])
	UiAnim.animZoomOut([$PanelContainer2])



func _on_upload_pressed():
	var file = File.new()
	var map_name = game_server.serverInfo.map
	var file_list = [
		"user://custom_maps/maps/" + map_name + ".tscn",
		"user://custom_maps/gameModes/TDM/" + map_name + ".tscn",
		"user://custom_maps/gameModes/Zombie/" + map_name + ".tscn"
		]
	var files = []
	
	for i in file_list:
		if file.file_exists(i):
			files.append(i)
	# Atleast 1 gamemode and a map should exist
	if files.size() < 2:
		var notice = Notice.new()
		notice.showNotice(self, "Error", "You need to create atleast 1 game mode", Color.red)
		return
	# Dict that will be uploaded
	var data_dict = {
		id = OS.get_unique_id(),
		lvl_name = map_name
	}
	
	# Read files
	for i in files:
		file.open(i, File.READ)
		var data = file.get_as_text()
		file.close()
		
		var sub_strings : Array = i.split("/")
		if sub_strings.has("maps"):
			data_dict["map"] = data
		elif sub_strings.has("TDM"):
			data_dict["TDM"] = data
		elif sub_strings.has("Zombie"):
			data_dict["Zombie"] = data
	
	$PanelContainer3.show()
	$PanelContainer2.hide()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# Upload Files
	var uploader = DataUploader.new(false)
	uploader.connect("connection_failed",  self, "on_upload_failed")
	uploader.connect("upload_failed", self, "on_upload_failed")
	var result = uploader.uploadData(data_dict, "levelReceiver.php")
	# Upload Minimap
	if result and file.file_exists("user://custom_maps/minimaps/" + map_name + "128.png"):
		$PanelContainer3.show()
		$PanelContainer3/Panel/Label.text = "uploading Minimap ..."
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		result = uploader.uploadFile("user://custom_maps/minimaps/" + map_name + "128.png", "fileReceiver.php")
		result = uploader.uploadData(data_dict, "minimapSetup.php")
		
	if result:
		on_upload_successful()
	
	uploader.queue_free()


# Show success msg
func on_upload_successful():
	var notice = Notice.new()
	notice.showNotice(self, "Done", "Your map was uploaded and will feature in Community maps",
	 Color.white, Color.green)
	notice.connect("notice_closed", $PanelContainer2, "show")
	$PanelContainer3.hide()

# Show failure msg
func on_upload_failed():
	var notice = Notice.new()
	notice.showNotice(self, "Failed", "Your map was not uploaded. Check your connection and try again", Color.red)
	notice.connect("notice_closed", $PanelContainer2, "show")
	$PanelContainer3.hide()
