extends CanvasLayer


var levels = Array()
var selected_level = null
var selected_level_id = 0
onready var selected_btn = $Panel/VBoxContainer/level
var selected_gameMode = null
var selected_gameMode_id = 0

var level_names = ["Dust","DesertComplex","Mansion"]

func _ready():
	$Admob.load_banner()
	game_server.bot_settings.bot_count = 0
	game_server.bot_settings.bot_difficulty = 1
	loadLevelInfos()
	network.connect("player_removed", self, "_on_player_removed")
	#show IP address 
	for i in IP.get_local_addresses():
		if ( !(i.substr(0,3) == "169") ) and i.length() < 15:
			$Label.text += "IP =" + i + "\n" 
	game_server.preloadParticles()
	selected_btn.self_modulate = Color8(66,210,41,255) 
	initialTween()
	$bots/bot_difficulty/bot_diff.value = 2
	$bots/bot_no/HSlider.value = 10


func loadLevelInfos():
	for i in level_names:
		var level_info = load("res://Maps/" + i + "/level_info.gd").new()
		levels.append(level_info)
	
	if not levels.empty():
		setLevelInfo(levels[0])
	else:
		print("No levels found")


func setLevelInfo(info):
	if selected_level != info:
		selected_level = info
		$level/icon.texture = selected_level.icon
		$level/desc/Label.text = selected_level.level_desc
		$level/icon/Label.text = selected_level.level_name
		if not selected_level.gameModes.empty():
			setGameModeInfo(selected_level.gameModes[0])

func setGameModeInfo(info):
	if selected_gameMode != info:
		selected_gameMode = info
		$gameMode/Panel/Label.text = info.name
		$gameMode/desc/Label.text = info.desc
	
func _start_game():
	$Admob.hide_banner()
	game_server.serverInfo.map = selected_level.level_name
	game_server.serverInfo.game_mode = selected_gameMode.name
	network.serverAvertiser.serverInfo = game_server.serverInfo
	network.add_child(network.serverAvertiser)
	get_tree().change_scene(selected_level.level_path)
	queue_free()

func _on_start_pressed():
	_start_game()

func _on_HSlider_value_changed(value):
	game_server.bot_settings.bot_count = value
	$bots/bot_no/Panel/count.text = String(value)


func _on_bot_diff_value_changed(value):
	MusicMan.click()
	game_server.bot_settings.bot_difficulty = value
	$bots/bot_difficulty/Panel/count.text = String(value)

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

func _on_level_pressed():
	if selected_btn != $Panel/VBoxContainer/level:
		MusicMan.click()
		$Panel/VBoxContainer/level.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/level
		changePanelTween("level")


func _on_GameMode_pressed():
	if selected_btn != $Panel/VBoxContainer/GameMode:
		MusicMan.click()
		$Panel/VBoxContainer/GameMode.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/GameMode
		changePanelTween("gameMode")


func _on_bots_pressed():
	if selected_btn != $Panel/VBoxContainer/bots:
		MusicMan.click()
		$Panel/VBoxContainer/bots.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/bots
		changePanelTween("bots")


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

#################################Tweening################################

onready var selected_panel = $level
var panel_pos : Vector2

func initialTween():
	panel_pos = selected_panel.rect_position
	selected_panel.rect_position += Vector2(0,400)
	$Tween.remove_all()
	$Tween.interpolate_property(selected_panel,"rect_position",selected_panel.rect_position,
	panel_pos,0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func changePanelTween(node_name : String):
	var node = get_node(node_name)
	if node == selected_panel:
		print("Error same node")
		return
		
	$Tween.remove_all()
	selected_panel.rect_position = panel_pos
	$Tween.interpolate_property(selected_panel,"rect_position",selected_panel.rect_position,
		selected_panel.rect_position + Vector2(650,0),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	node.rect_position = panel_pos - Vector2(0,650)
	$Tween.interpolate_property(node,"rect_position",node.rect_position,panel_pos,
		0.5,Tween.TRANS_QUAD,Tween.EASE_OUT,0.2)
	selected_panel = node
	$Tween.start()

