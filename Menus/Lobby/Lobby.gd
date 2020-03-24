extends CanvasLayer

var _selected_level = 0
var levels = Array()
onready var selected_btn = $Panel/VBoxContainer/level

func _ready():
	game_server.bot_settings.bot_count = 0
	game_server.bot_settings.bot_difficulty = 1
	setLevels()
	network.connect("player_removed", self, "_on_player_removed")
	#show IP address 
	for i in IP.get_local_addresses():
		if ( !(i.substr(0,3) == "169") ) and i.length() < 15:
			$Label.text += "IP =" + i + "\n" 
	game_server.preloadParticles()
	selected_btn.self_modulate = Color8(66,210,41,255) 
	initialTween()


func setLevels():
	var dir = Directory.new()
	dir.change_dir("res://Maps")
	dir.list_dir_begin()
	var d = dir.get_next()
	while d != "":
		if d.get_extension() == "" and not d.begins_with("."):
			levels.append(d)
		d = dir.get_next()
	
	for i in levels:
		$level/level.add_item(i)

#level is selected
func _on_level_item_selected(ID):
	_selected_level = ID
	print(ID)

func _start_game():
	network.serverAvertiser.serverInfo.map = levels[_selected_level]
	var level_path = "res://Maps/" + levels[_selected_level] + "/" + levels[_selected_level] + ".tscn"
	get_tree().change_scene(level_path)
	queue_free()

func _on_start_pressed():
	_start_game()

func _on_HSlider_value_changed(value):
	game_server.bot_settings.bot_count = value
	$bots/bot_no/Panel/count.text = String(value)


func _on_bot_diff_value_changed(value):
	game_server.bot_settings.bot_difficulty = value
	$bots/bot_difficulty/Panel/count.text = String(value)

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
		selected_panel.rect_position + Vector2(550,0),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	node.rect_position = panel_pos - Vector2(0,550)
	$Tween.interpolate_property(node,"rect_position",node.rect_position,panel_pos,
		0.5,Tween.TRANS_QUAD,Tween.EASE_OUT,0.2)
	selected_panel = node
	$Tween.start()


func _on_level_pressed():
	if selected_btn != $Panel/VBoxContainer/level:
		$Panel/VBoxContainer/level.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/level
		changePanelTween("level")


func _on_GameMode_pressed():
	if selected_btn != $Panel/VBoxContainer/GameMode:
		$Panel/VBoxContainer/GameMode.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/GameMode
		changePanelTween("gameMode")


func _on_bots_pressed():
	if selected_btn != $Panel/VBoxContainer/bots:
		$Panel/VBoxContainer/bots.self_modulate = selected_btn.self_modulate
		selected_btn.self_modulate = Color8(255,255,255,255)
		selected_btn = $Panel/VBoxContainer/bots
		changePanelTween("bots")
