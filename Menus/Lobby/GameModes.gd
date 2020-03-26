extends CanvasLayer

func _ready():
	pass # Replace with function body.

func _on_FFA_pressed():
	network.serverAvertiser.serverInfo.game_mode = "FFA"
	game_server.serverInfo = network.serverAvertiser.serverInfo
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")

func _on_TDM_pressed():
	network.serverAvertiser.serverInfo.game_mode = "TDM"
	game_server.serverInfo = network.serverAvertiser.serverInfo
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")

func _on_ZM_pressed():
	network.serverAvertiser.serverInfo.game_mode = "SURVIVAL"
	game_server.serverInfo = network.serverAvertiser.serverInfo
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")

func _on_back_pressed():
	network.stopServer()
	get_tree().change_scene("res://Menus/MainMenu/host_menu.tscn")
