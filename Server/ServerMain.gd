extends Node

var Levels = Array()
var selected_level = null

var server_name = "Server 1"
var map = ""
var game_mode = ""
var game_mode_id = 1
var bot_count = 9
var bot_difficulty = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	loadStandardLevelData()
	network.create_server(server_name, 6969 , 10)
	print("Creating server at port 6969")
	for i in IP.get_local_addresses():
		print("Address : ", i)
	
	loadLevel()


func loadStandardLevelData():
	var level_info = load("res://Maps/level_info.gd").new()
	Levels = level_info.levels.values()
	if Levels.empty():
		print("Unable to Load level info")
		get_tree().quit()
	
	selected_level = Levels[0]
	game_mode = selected_level.game_modes[game_mode_id * 2]



func loadLevel():
	game_server.serverInfo.map = selected_level.name
	game_server.serverInfo.game_mode = game_mode
	#game_server.game_mode_settings = getModeSettings()
	game_server.bot_settings.bot_count = bot_count
	
	game_server.bot_settings.bot_difficulty = bot_difficulty
	
	if selected_level.has("author"):
		game_server.serverInfo.author = selected_level.author
	
	network.serverAvertiser.serverInfo = game_server.serverInfo
	network.add_child(network.serverAvertiser)
	get_tree().change_scene(selected_level.game_modes[game_mode_id * 2 + 1])
	queue_free()
