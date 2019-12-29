extends CanvasLayer

var _selected_game_mode = 0
var _selected_level = 0

func _ready():
	network.connect("player_list_changed", self, "_on_player_list_changed")
	#Connected players list
	var nlabel = Label.new()
	nlabel.text = game_states.player_info.name
	if game_states.player_info.net_id == 1:
		nlabel.text += " (HOST)"
	$PanelContainer/Panel/players.add_child(nlabel)
	
	if (get_tree().is_network_server()):
		network.connect("player_removed", self, "_on_player_removed")
		#show IP address 
		#remove ip6 address
		for i in IP.get_local_addresses():
			if ( !(i.substr(0,3) == "169") ) and i.length() < 15:
				$Label.text += "IP =" + i + "\n" 
	else:
		$PanelContainer2/Panel/level.disabled = true
		$PanelContainer/Panel/start.disabled = true
		$PanelContainer2/Panel/game_mode.disabled = true

	$PanelContainer2/Panel/level.add_item("Dust")
	$PanelContainer2/Panel/level.add_item("Dust II")
	$PanelContainer2/Panel/game_mode.add_item("Free For All")
	$PanelContainer2/Panel/game_mode.add_item("TDM")
	$PanelContainer2/Panel/game_mode.add_item("Survival")
	_on_game_mode_item_selected(_selected_game_mode)
	_on_level_item_selected(_selected_level)


#refresh player list
func _on_player_list_changed():
	for c in $PanelContainer/Panel/players.get_children():
		c.queue_free()
	for p in network.players:
		var nlabel = Label.new()
		nlabel.text = network.players[p].name
		if network.players[p].net_id == 1:
			nlabel.text += " (HOST)"
		$PanelContainer/Panel/players.add_child(nlabel)
	#Sync selections with newly connected peer
	if get_tree().is_network_server():
		rpc("_select_level",_selected_level)
		rpc("_select_mode",_selected_game_mode)

#level is selected
func _on_level_item_selected(ID):
	_selected_level = ID
	rpc("_select_level",ID)

remote func _select_level(ID):
	$PanelContainer2/Panel/level.select(ID)


remote func _start_game():
	get_tree().change_scene("res://Objects/Temp/Node2D.tscn")
	queue_free()

func _on_start_pressed():
	rpc("_start_game")
	_start_game()

remote func _select_mode(ID):
	$PanelContainer2/Panel/game_mode.select(ID)
	var mode = $PanelContainer2/Panel/game_mode.get_item_text(ID)
	if mode == "Free For All":
		game_states.GAME_MODE = game_states.GAME_MODES.FFA
	elif mode == "TDM":
		game_states.GAME_MODE = game_states.GAME_MODES.TDM
	elif mode == "Survival":
		game_states.GAME_MODE = game_states.GAME_MODES.SURVIVAL

#game mode is selected
func _on_game_mode_item_selected(ID):
	_selected_game_mode = ID
	var mode = $PanelContainer2/Panel/game_mode.get_item_text(ID)
	if mode == "Free For All":
		game_states.GAME_MODE = game_states.GAME_MODES.FFA
	elif mode == "TDM":
		game_states.GAME_MODE = game_states.GAME_MODES.TDM
	elif mode == "Survival":
		game_states.GAME_MODE = game_states.GAME_MODES.SURVIVAL
	rpc("_select_mode",ID)
