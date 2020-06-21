extends CanvasLayer


var levels = Array()
var selected_level = null
var selected_level_id = 0

var selected_gameMode = ["",""]
var selected_gameMode_id = 0




func _ready():
	game_server.bot_settings.bot_count = 0
	game_server.bot_settings.bot_difficulty = 1
	loadLevelInfos()
	network.connect("player_removed", self, "_on_player_removed")
	#show IP address 
	for i in IP.get_local_addresses():
		if ( !(i.substr(0,3) == "169") ) and i.length() < 15:
			$Label.text += "IP =" + i + "\n" 

	UiAnim.animLeftToRight([$Panel])
	$Panel/TabContainer/Bots/bot_difficulty/bot_diff.value = 2
	$Panel/TabContainer/Bots/bot_no/HSlider.value = 10


func loadLevelInfos():
	var level_info = load("res://Maps/level_info.gd").new()
	levels = level_info.levels.values()
	level_info.queue_free()
	selected_level_id = 0
	
	if not levels.empty():
		setLevelInfo(levels[0])
	else:
		Logger.LogError("loadLevelInfos", "Failed to load levels")


func setLevelInfo(info):
	if selected_level != info:
		selected_level = info
		$Panel/portrait/TextureRect.texture = selected_level.icon
		$Panel/portrait/level_name.text = selected_level.name
		
		if selected_gameMode[0] == "":
			selected_gameMode[0] = selected_level.game_modes[0]
			selected_gameMode[1] = selected_level.game_modes[1]
			selected_gameMode_id = 0

		elif not selected_level.game_modes.has(selected_gameMode):
			selected_gameMode[0] = selected_level.game_modes[0]
			selected_gameMode[1] = selected_level.game_modes[1]
			selected_gameMode_id = 0
		
		$Panel/TabContainer/Game/mode/mode.text = selected_gameMode[0]


func setGameModeInfo(info):
	if selected_gameMode != info:
		selected_gameMode = info
		$gameMode/Panel/Label.text = info.name


func _start_game():
	game_server.serverInfo.map = selected_level.name
	game_server.serverInfo.game_mode = selected_gameMode[0]
	network.serverAvertiser.serverInfo = game_server.serverInfo
	network.add_child(network.serverAvertiser)
	get_tree().change_scene(selected_gameMode[1])
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
	if levels.size() > 1:
		MusicMan.click()
		if selected_level_id == 0:
			selected_level_id = levels.size()
		selected_level_id -= 1
		setLevelInfo(levels[selected_level_id])


func _on_next_map_pressed():
	if levels.size() > 1:
		MusicMan.click()
		if selected_level_id + 1 == levels.size():
			selected_level_id = -1
		selected_level_id += 1
		setLevelInfo(levels[selected_level_id])




func _on_prev_mode_pressed():
	if selected_level and selected_level.gameModes.size() > 1:
		MusicMan.click()
		if selected_gameMode_id == 0:
			selected_gameMode_id = selected_level.gameModes.size()
		selected_gameMode_id -= 1
		setGameModeInfo(selected_level.gameModes[selected_gameMode_id])


func _on_next_mode_pressed():
	if selected_level and selected_level.gameModes.size() > 1:
		MusicMan.click()
		if selected_gameMode_id + 1 == selected_level.gameModes.size():
			selected_gameMode_id = -1
		selected_gameMode_id += 1
		setGameModeInfo(selected_level.gameModes[selected_gameMode_id])





func _on_mode_pressed():
	selected_gameMode_id += 2
	if selected_level.game_modes.size() <= selected_gameMode_id:
		selected_gameMode_id = 0
	
	selected_gameMode[0] = selected_level.game_modes[selected_gameMode_id]
	selected_gameMode[1] = selected_level.game_modes[selected_gameMode_id + 1]
	$Panel/TabContainer/Game/mode/mode.text = selected_gameMode[0]


func _on_CheckButton_toggled(button_pressed):
	game_server.extraServerInfo.friendly_fire = button_pressed
