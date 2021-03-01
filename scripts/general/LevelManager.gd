# Script to Manage Level loading and Level changes
extends Node

var settings = {}

signal level_loaded

func _ready():
	name = "LevelManager"
	_connectSignals()

func _connectSignals():
	var network = get_tree().root.get_node("NetworkManager")
	network.connect("disconnected", self, "_on_disconnected_from_server")
	connect("level_loaded", self, "_on_level_loaded")


# Load Level
func loadLevel():
	var level_name = settings.level.name
	var game_mode = settings.level.mode
	var config = _readLevelConfig(level_name)
	var level_scene_path = config.modes.get(game_mode)
	if level_scene_path:
		var level = load(level_scene_path).instance()
		get_tree().root.add_child(level)
		emit_signal("level_loaded")


# only for clients
func joinLevel():
	query_levelSettings()


# Read level config
func _readLevelConfig(level_name):
	var config_file = "res://resources/levels/" + level_name + "/level_info.json"
	var config = Utility.loadDictionary(config_file)
	return config


# To Do
func changeLevelTo(_level_name):
	pass


# Called when disconnected from server
func _on_disconnected_from_server():
	# Cleanup
	var cleanup_script = load("res://scripts/general/Cleanup.gd").new()
	get_tree().root.add_child(cleanup_script)
	cleanup_script.cleanUP()

# Update serverAdvertiser
func _on_level_loaded():
	if get_tree().is_network_server():
		var server_advertiser = get_tree().root.get_node("NetworkManager/ServerAdvertiser")
		server_advertiser.serverInfo.map = settings.level.name
		server_advertiser.serverInfo.game_mode = settings.level.mode

########################################### Network Code ########################################
func query_levelSettings():
	rpc_id(1, "S_levelSettings", get_tree().get_network_unique_id())


remote func S_levelSettings(peer_id : int):
	rpc_id(peer_id, "C_levelSettings", settings)


remote func C_levelSettings(data):
	settings = data
	print("LevelManager::Got Level info from the server")
	loadLevel()
