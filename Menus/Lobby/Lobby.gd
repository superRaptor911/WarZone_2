extends CanvasLayer

# Level Groups
var standard_levels = LinkedList.new()
var my_levels = LinkedList.new()
var downloaded_levels = LinkedList.new()

# Selected group
var selected_level_group = null
# Selected Level
var selected_level = null

var selected_mode = "classic"
var selected_Mode_id = 0


func _ready():
	game_server.bot_settings.bot_count = 0
	game_server.bot_settings.bot_difficulty = 1
	loadStandardLevelData()
	loadMyLevelData()
	loadDownloadedLevelData()
	network.connect("player_removed", self, "_on_player_removed")
	
	# Show IP address 
	for i in IP.get_local_addresses():
		if i.substr(0,3) != "127" and i.length() < 15:
			$Label.text += "IP =" + i + "\n" 

	UiAnim.animLeftToRight([$Panel])
	#$Panel/TabContainer/Bots/bot_difficulty/bot_diff.value = 2
	#$Panel/TabContainer/Bots/bot_no/HSlider.value = 10
	$Panel/Panel/gameModesList.select(0)
	configGameModes()

# Load Standard Level, i.e default lvls
func loadStandardLevelData():
	var level_info = load("res://Maps/level_info.gd").new()
	var _levels = level_info.levels.values()
	level_info.queue_free()
	# Fill list
	for i in _levels:
		# Dont include debug levels for android
		if not (i.debug and game_states.is_android):
			standard_levels.addElement(i)
	# Select first level in list
	if not standard_levels.is_empty:
		setLevelInfo(standard_levels.first)
	else:
		Logger.LogError("loadLevelInfos", "Failed to load levels")
		$Panel/mapGroup/standardMaps.disabled = true
	selected_level_group = standard_levels

# Load Levels created by user
func loadMyLevelData():
	$Panel/mapGroup/myMaps.disabled = true
	var dir = Directory.new()
	# Check if custom map dir exists
	if dir.open("user://custom_maps/") != OK:
		return
	dir.list_dir_begin()
	var file_name : String= dir.get_next()
	# Read config files
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.get_extension() == "dat":
				var data = game_states.load_data("user://custom_maps/"+file_name, false)
				var img = Image.new()
				img.load(data.icon)
				var img_tex = ImageTexture.new()
				img_tex.create_from_image(img)
				data.icon = img_tex
				data.author = String(OS.get_unique_id())
				my_levels.addElement(data)
				$Panel/mapGroup/myMaps.disabled = false
				
		file_name = dir.get_next()

# Load downloaded levels
func loadDownloadedLevelData():
	$Panel/mapGroup/downloadedMaps.disabled = true
	var download_dir = "user://downloads/"
	var authors_dir = Directory.new()
	if authors_dir.open(download_dir) != OK:
		return
	
	authors_dir.list_dir_begin()
	var author_id = authors_dir.get_next()
	# Levels are saved ad downloads/author_id/custom_maps/
	# iterate over anuthor_ids
	while author_id != "":
		if authors_dir.current_is_dir() and author_id != "." and author_id != "..":
			var dir = Directory.new()
			dir.open(download_dir + author_id + "/custom_maps/")
			dir.list_dir_begin()
			var file_name : String= dir.get_next()
			# Read config files
			while file_name != "":
				if not dir.current_is_dir() and file_name != "." and file_name != "..":
					if file_name.get_extension() == "dat":
						var data = game_states.load_data(download_dir + author_id + "/custom_maps/" + file_name, false)
						var img = Image.new()
						img.load(data.icon)
						print(download_dir + author_id + "/custom_maps/" + file_name)
						var img_tex = ImageTexture.new()
						img_tex.create_from_image(img)
						data.icon = img_tex
						data.author = author_id
						downloaded_levels.addElement(data)
						$Panel/mapGroup/downloadedMaps.disabled = false
						
				file_name = dir.get_next()
		author_id = authors_dir.get_next()


func configGameModes():
	var mode_list = $Panel/Panel/gameModesList
	mode_list.clear()
	var count = selected_level.game_modes.size() / 2
	for i in range(count):
		var mode = selected_level.game_modes[i * 2]
		mode_list.add_item(mode)
	mode_list.select(0)
	_on_gameModesList_item_selected(0)


func setLevelInfo(info):
	if selected_level != info:
		selected_level = info
		$Panel/portrait/TextureRect.texture = selected_level.icon
		$Panel/portrait/level_name.text = selected_level.name
		configGameModes()
		
		#$Panel/TabContainer/Game/mode/mode.text = selected_gameMode[0]


func _start_game():
	game_server.serverInfo.map = selected_level.name
	game_server.serverInfo.game_mode = selected_mode
	if selected_level.has("author"):
		game_server.serverInfo.author = selected_level.author
	
	network.serverAvertiser.serverInfo = game_server.serverInfo
	network.add_child(network.serverAvertiser)
	get_tree().change_scene(selected_level.game_modes[selected_Mode_id * 2 + 1])
	queue_free()


func _on_start_pressed():
	_start_game()

func _on_HSlider_value_changed(value):
	MusicMan.click()
	game_server.bot_settings.bot_count = value
	$Panel/TabContainer/Bots/bot_no/Panel/count.text = String(value)


func _on_bot_diff_value_changed(value):
	MusicMan.click()
	game_server.bot_settings.bot_difficulty = value
	$Panel/TabContainer/Bots/bot_difficulty/Panel/count.text = String(value)

func _on_prev_map_pressed():
	if not selected_level_group.is_empty:
		MusicMan.click()
		setLevelInfo(selected_level['prev'])


func _on_next_map_pressed():
	if not selected_level_group.is_empty:
		MusicMan.click()
		setLevelInfo(selected_level['next'])


func _on_CheckButton_toggled(button_pressed):
	game_server.extraServerInfo.friendly_fire = button_pressed

func deselectButtons():
	for i in $Panel/mapGroup.get_children():
		i.pressed = false

func _on_standardMaps_pressed():
	deselectButtons()
	$Panel/mapGroup/standardMaps.pressed = true
	selected_level_group = standard_levels
	setLevelInfo(selected_level_group.first)


func _on_myMaps_pressed():
	deselectButtons()
	$Panel/mapGroup/myMaps.pressed = true
	selected_level_group = my_levels
	setLevelInfo(selected_level_group.first)


func _on_downloadedMaps_pressed():
	deselectButtons()
	$Panel/mapGroup/downloadedMaps.pressed = true
	selected_level_group = downloaded_levels
	setLevelInfo(selected_level_group.first)


func hideLevelSettings():
	for i in $Panel/TabContainer/Game.get_children():
		i.hide()



func _on_gameModesList_item_selected(index):
	var mode_name = $Panel/Panel/gameModesList.get_item_text(index)
	selected_mode = mode_name
	selected_Mode_id = index
	match mode_name:
		"Classic":
			hideLevelSettings()
			$Panel/TabContainer/Game/classic.show()
		"TDM":
				hideLevelSettings()
				$Panel/TabContainer/Game/tdm.show()
		"Zombie Mod":
			hideLevelSettings()
			$Panel/TabContainer/Game/classic.show()
