extends Control

var Levels_dict = {}
var cur_map = null

func _ready():
	var download = DataUploader.new()
	Levels_dict = download.getData("getLevelInfo.php")
	UiAnim.animLeftToRight([$Panel])
	fillMapList()


func fillMapList():
	var itemList = $Panel/mapList
	
	for i in Levels_dict:
		var lvl_info = Levels_dict.get(i)
		var text = "   " + lvl_info.name + " [ "
		for m in lvl_info.game_modes:
			text += m + " "
		text += "]"
		itemList.add_item(text)


func _on_mapList_item_selected(index):
	$mapInfo.show()
	$Panel.hide()
	UiAnim.animZoomIn([$mapInfo])
	var text = "Map Name : %s\nAuthor : %s"
	var levels = Levels_dict.values()
	var lvl_name = levels[index].name
	var author_name = "unknown"
	
	if levels[index].has("author_name") and levels[index].author_name != "":
		author_name = levels[index].author_name
	
	$mapInfo/Label.text = text % [lvl_name, author_name]
	cur_map = levels[index]


func _on_back_pressed():
	$mapInfo.hide()
	$Panel.show()
	UiAnim.animZoomIn([$Panel])


func _onMapinfo_back_pressed():
	$mapInfo.hide()
	$Panel.show()
	UiAnim.animZoomIn([$Panel])


func _on_install_pressed():
	var downloader = DataUploader.new()
	var data = downloader.getData("levelDownloader.php", cur_map)
	
	var dir = Directory.new()
	dir.make_dir("user://custom_maps/")
	dir.make_dir("user://custom_maps/maps")
	dir.make_dir("user://custom_maps/gameModes")
	dir.make_dir("user://custom_maps/gameModes/TDM")
	dir.make_dir("user://custom_maps/gameModes/Zombie")
	dir.make_dir("user://custom_maps//minimaps")
	dir.make_dir("user://custom_maps/levels")
	
	var map_file_name = cur_map.author + cur_map.name + ".tscn"
	var map_path = "user://custom_maps/maps/" + map_file_name
	
	var file = File.new()
	file.open(map_path, File.WRITE)
	file.store_string(data.base_map)
	file.close()
	
	for i in data.game_modes:
		var mode_file = "user://custom_maps/gameModes/" + i + "/" + map_file_name
		file.open(mode_file, File.WRITE)
		file.store_string(data.game_modes.get(i))
		file.close()
	
	convert_map()



func convert_map():
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
	var map_name = cur_map.author + cur_map.name
	
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
		level_node.Level_Name = cur_map.name
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
		level_node.Level_Name = cur_map.name
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
		var save_path = "user://custom_maps/levels/ZM_" + map_name + ".tscn"
		if result == OK:
			ResourceSaver.save(save_path, packed_scene)
		# Free resources
		level_node.remove_child(base_map)
		final_level.remove_child(game_modes[1])
		final_level.queue_free()
	
	# Write config
	levelInfo.name = cur_map.name
	levelInfo.icon= "user://custom_maps/minimaps/" + map_name + ".png"
	
	var counter = false
	
	if game_modes[0]:
		levelInfo.game_modes.append("TDM")
		levelInfo.game_modes.append("user://custom_maps/levels/TDM_" + map_name + ".tscn")
		game_modes[0].queue_free()
		counter = true
	
	if game_modes[1]:
		levelInfo.game_modes.append("Zombie Mod")
		levelInfo.game_modes.append("user://custom_maps/levels/ZM_" + map_name + ".tscn")
		game_modes[1].queue_free()
		counter = true
	
	base_map.queue_free()
	if (not counter):
		var notice = Notice.new()
		notice.showNotice(self, "Failed", 
		"Game Mode not found. Create a Game Mode by pressing GAME MODE EDITOR.", Color.red)
		return
	var save_path = "user://custom_maps/" + map_name + ".dat"
	game_states.save_data(save_path, levelInfo, false)
