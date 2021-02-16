extends Node

var settings = {}

func _ready():
	name = "LevelManager"


func loadLevel():
	var level_name = settings.level.name
	var game_mode = settings.level.mode
	var config = _readLevelConfig(level_name)
	var level_scene_path = config.get(game_mode)
	if level_scene_path:
		var level = load(level_scene_path).instance()
		get_tree().root.add_child(level)



func _readLevelConfig(level_name):
	var config_file = "res://resources/levels/" + level_name + "/level_info.rjs"
	var config = Utility.loadDictionary(config_file)
	return config


# To Do

func changeLevelTo(level_name):
	pass


########################################### Network Code ########################################
func query_levelSettings():
	rpc_id(1, "S_levelSettings", get_tree().get_network_unique_id())


remote func S_levelSettings(peer_id : int):
	rpc_id(peer_id, "C_levelSettings", settings)


remote func C_levelSettings(data):
	settings = data
	print("LevelManager::Got Level info from the server")
	loadLevel()
