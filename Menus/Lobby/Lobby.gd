extends CanvasLayer

var _selected_level = 0
var levels = Array()

func _ready():
	setLevels()
	network.connect("player_removed", self, "_on_player_removed")
	#show IP address 
	for i in IP.get_local_addresses():
		if ( !(i.substr(0,3) == "169") ) and i.length() < 15:
			$Label.text += "IP =" + i + "\n" 
	game_server.preloadParticles()


func setLevels():
	levels.append("TestMap")
	for i in levels:
		$PanelContainer2/Panel/level.add_item(i)

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
