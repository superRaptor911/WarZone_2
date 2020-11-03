extends Control


var level_info = preload("res://Maps/level_info.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("join_fail", self, "_on_join_fail")
	network.connect("join_success", self, "on_server_joined")
	game_server.connect("synced_serverInfo", self, "_join_game")
	var notice = Notice.new()
	notice.showNotice(self, "Warning !", 
		"This is an experimental feature. Work is in progress.\nGame may crash", 
		Color.red)
	MenuManager.connect("back_pressed", self, "on_back_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_join_s1_pressed():
	network.join_server("35.225.247.110",6969)
	$Label.text = "Connecting . . ."
	$Label.show()
	

func _on_join_fail():
	print("Failed to join server")
	$Label.text = "Failed"
	$Label.show()
	yield(get_tree().create_timer(2), "timeout")
	$Label.hide()
	


func on_server_joined():
	game_server.rpc_id(1, "getServerInfo", game_states.player_info.net_id)


func _join_game():
	var current_server = game_server.serverInfo
	var l_info = level_info.getLevelInfo(current_server.map)
	
	if l_info == {}:
		Logger.LogError("_join_game", "Map %s does not exist." % [current_server.map])
		return
	
	var l_path = level_info.getLevelGameModePath(l_info, current_server.game_mode)
	
	if l_path == "":
		Logger.LogError("_join_game", "Map %s does not have game mode %s" % [current_server.map, current_server.game_mode])
		return
	get_tree().change_scene(l_path)


func _on_join_s2_pressed():
	network.join_server("35.240.187.237",6969)
	$Label.text = "Connecting . . ."
	$Label.show()


func on_back_pressed():
	MenuManager.changeScene("newGame")
