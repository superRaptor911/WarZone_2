extends Control

var Levels_dict = {}
var no_img_tex = preload("res://Sprites/misc/icons8-no-image-100.png")
var cur_map = null


func _ready():
	UiAnim.animLeftToRight([$Panel])
	yield(get_tree().create_timer(UiAnim.getAnimDuration() + 0.2), "timeout")
	fillMapList(true)
	MenuManager.connect("back_pressed", self, "on_back_pressed")

# Load Level data and Fill Menu
func fillMapList(use_cache = false):
	if use_cache:
		if loadFromCache():
			return
		
	Levels_dict = {}
	$info.show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var downloader = DataUploader.new()
	# connect signals
	downloader.connect("connection_failed", self , "on_connection_failed")
	downloader.connect("download_failed", self , "on_download_failed")
	downloader.connect("download_finished", $info, "hide")
	# Download map list
	Levels_dict = downloader.getData("getLevelInfo.php")
	
	var itemList = $Panel/mapList
	itemList.clear()
	
	if Levels_dict == {} or Levels_dict == null:
		return
	
	$info/Label.text = "Loading images (%d/ %d)\nWait will take time" % [0 , Levels_dict.size()]
	$info.show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Cache Dir
	var base_dir = "user://Cache/Levels/"
	var dir = Directory.new()
	dir.make_dir_recursive(base_dir)
	game_states.save_data(base_dir + "lvls.dat", Levels_dict, false)
	var count = 0
	# Download images and fill menu
	for i in Levels_dict:
		count += 1		#Increase count
		var lvl_info = Levels_dict.get(i)
		# Show available game modes
		var text = "   " + lvl_info.name + " [ "
		for m in lvl_info.game_modes:
			text += m + " "
		text += "]"
		
		# Downlaod image
		var dat = downloader.getFile("minimapDownloader.php", lvl_info)
		# Show progress
		$info/Label.text = "Loading images (%d/ %d)\nWait will take time" % [count , Levels_dict.size()]
		$info.show()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		# Convert Image into texture
		var image = Image.new()
		if image.load_png_from_buffer(dat) != OK:
			print("An error occurred while trying to display the image.")
			itemList.add_item(text, no_img_tex)
			continue
		# Save image cache
		image.save_png(base_dir + lvl_info.author + lvl_info.name + ".png")
		# Fill menu
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		itemList.add_item(text, texture)
		$info.hide()

# Load Level data from cache
func loadFromCache() -> bool:
	Levels_dict = game_states.load_data("user://Cache/Levels/lvls.dat", false)
	if not Levels_dict:
		return false
		
	for i in Levels_dict:
		var lvl_info = Levels_dict.get(i)
		# Show available game modes
		var text = "   " + lvl_info.name + " [ "
		for m in lvl_info.game_modes:
			text += m + " "
		text += "]"
		
		# Convert Image into texture
		var image = Image.new()
		if image.load("user://Cache/Levels/" + lvl_info.author + lvl_info.name+ ".png") != OK:
			print("An error occurred while trying to display the image.")
			$Panel/mapList.add_item(text, no_img_tex)
			continue
		# Fill menu
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		$Panel/mapList.add_item(text, texture)
		$info.hide()
	return true
	


func _on_mapList_item_selected(index):
	$mapInfo.show()
	$Panel.hide()
	UiAnim.animZoomIn([$mapInfo])
	var text = "Map Name : %s\nAuthor : %s"
	var levels = Levels_dict.values()
	var lvl_name = levels[index].name
	var author_name = "unknown"
	
#	var downloader = DataUploader.new()
#	var dat = downloader.getFile("minimapDownloader.php", levels[index])
#	var image = Image.new()
#	if image.load_png_from_buffer(dat) != OK:
#		print("An error occurred while trying to display the image.")
#	var texture = ImageTexture.new()
#	texture.create_from_image(image)
#	$mapInfo/TextureRect.texture = texture
	
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
	# Show label
	$info.show()
	$info/Label.text = "Downloading . . ."
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var downloader = DataUploader.new()
	# Connect Signals
	downloader.connect("connection_failed", self , "on_connection_failed")
	downloader.connect("download_failed", self , "on_download_failed")
	downloader.connect("download_finished", $info, "hide")
	# Download cur_map
	var data = downloader.getData("levelDownloader.php", cur_map)
	
	# Chk data
	if data == {} or data == null:
		print(cur_map)
		return
	
	var base_dir = "user://downloads/" + cur_map.author + "/custom_maps/"
	# Make custom dirs
	var dir = Directory.new()
	dir.make_dir_recursive(base_dir)
	dir.make_dir(base_dir + "maps")
	dir.make_dir(base_dir + "gameModes")
	dir.make_dir(base_dir + "minimaps")
	dir.make_dir(base_dir + "levels")
	
	var map_file_name = cur_map.name + ".tscn"
	var map_path = base_dir + "maps/" + map_file_name
	# Save base map
	var file = File.new()
	file.open(map_path, File.WRITE)
	file.store_string(data.base_map)
	file.close()
	# Save game modes
	for i in data.game_modes:
		dir.make_dir(base_dir + "gameModes/" + i)
		var mode_file = base_dir + "gameModes/" + i + "/" + map_file_name
		file.open(mode_file, File.WRITE)
		file.store_string(data.game_modes.get(i))
		file.close()
	# Inastall map
	installMap()



func installMap():
	var levelInfo = {
		name = "Dust II",
		icon = "",
		game_modes = [
			],
		desc = "",
		debug = false
	}
	
	var base_map = null
	var map_name = cur_map.name
	var base_dir = "user://downloads/" + cur_map.author + "/custom_maps/"
	
	var file = File.new()
	var file_name = base_dir + "maps/" + map_name + ".tscn"
	if file.file_exists(file_name):
		base_map = load(file_name).instance()
		base_map.name = "BaseMap"
		base_map.force_update = false
	else:
		var notice = Notice.new()
		notice.showNotice(self, "Failed", 
		"Map not Found. Create Map by pressing MAP EDITOR.", Color.red)
		return
	
	# Add modes
	for mode in cur_map.game_modes:
		file_name = base_dir + "gameModes/" + mode + "/" + map_name + ".tscn"
		if file.file_exists(file_name):
			var final_level = Node.new()
			final_level.name = mode
			var level_node = Node2D.new()
			level_node.name = "Level"
			level_node.set_script(load("res://Maps/BaseLevel.gd"))
			
			level_node.Level_Name = map_name
			level_node.author = cur_map.author
			level_node.add_to_group("Level", true)
			final_level.add_child(level_node)
			level_node.owner = final_level
			
			level_node.add_child(base_map)
			base_map.owner = final_level
			var game_mode_scn = load(file_name).instance()
			game_mode_scn.name = "GameMode"
			final_level.add_child(game_mode_scn)
			game_mode_scn.owner = final_level
			
			# Save scene
			var packed_scene = PackedScene.new()
			var result = packed_scene.pack(final_level)
			var save_path = base_dir + "levels/" + mode + "_" + map_name + ".tscn"
			if result == OK:
				ResourceSaver.save(save_path, packed_scene)
			# Free resources
			level_node.remove_child(base_map)
			final_level.queue_free()
	
	# Write config
	levelInfo.name = cur_map.name
	levelInfo.icon= base_dir + "minimaps/" + map_name + ".png"
	
	var counter = false
	
	if cur_map.game_modes.has("TDM"):
		levelInfo.game_modes.append("TDM")
		levelInfo.game_modes.append(base_dir + "levels/TDM_" + map_name + ".tscn")
		counter = true
	
	if cur_map.game_modes.has("Zombie"):
		levelInfo.game_modes.append("Zombie Mod")
		levelInfo.game_modes.append(base_dir + "levels/Zombie_" + map_name + ".tscn")
		counter = true
	
	if not counter:
		base_map.queue_free()
		print(cur_map.game_modes)
		on_map_not_installed()
		return

	var save_path = base_dir + map_name + ".dat"
	game_states.save_data(save_path, levelInfo, false)
	
	var viewport = Viewport.new()
	var camera = Camera2D.new()
	add_child(viewport)
	viewport.add_child(camera)
	
	# Gen Minimap
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	viewport.render_target_v_flip = true
	viewport.size = (base_map.get_used_rect().size + base_map.get_used_rect().position+Vector2(1,1)) * 8
	viewport.add_child(base_map)
	camera.current = true
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.position = Vector2(0,0)
	camera.zoom = Vector2(1,1) * 8
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var minimap_path = base_dir + "minimaps/" + map_name + ".png"
	var image = viewport.get_texture().get_data()
	
	image.save_png(minimap_path)
	viewport.queue_free()
	on_map_installed()

################################################################################

func on_connection_failed():
	$info.show()
	$info/Label.text = "Connection Failed"
	yield(get_tree().create_timer(1.5), "timeout")
	$info.hide()

func on_download_failed():
	$info.show()
	$info/Label.text = "Download failed"
	yield(get_tree().create_timer(1.5), "timeout")
	$info.hide()

func on_map_not_installed():
	$info.show()
	$info/Label.text = "Map not installed"
	yield(get_tree().create_timer(1.5), "timeout")
	$info.hide()

func on_map_installed():
	$info.show()
	$info/Label.text = "Map installed"
	yield(get_tree().create_timer(1.5), "timeout")
	$info.hide()


func _on_refresh_list_pressed():
	yield(get_tree().create_timer(0.2), "timeout")
	fillMapList()

func on_back_pressed():
	MenuManager.changeScene("CommunityMenu")
