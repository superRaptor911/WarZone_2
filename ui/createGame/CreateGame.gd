extends Control

onready var start_game : Button = get_node("horizontal/config/start")

var network = null

func _ready():
	_connectSignals()

func _connectSignals():
	start_game.connect("pressed", self, "_on_start_pressed")


func _on_start_pressed():
	_initNetwork()


func _initNetwork():
	network = load("res://scripts/networking/Network.gd").new()
	get_tree().root.add_child(network)
	network.connect("server_creation_failed", self, "_on_server_creation_failed")
	network.connect("server_creation_success", self, "_on_server_creation_success")
	network.createServer()
	

func _on_server_creation_failed():
	network.queue_free()
	network = null
	get_node("failed2connect_dialog").show()


func _on_server_creation_success():
	var level_manager = load("res://scripts/general/LevelManager.gd").new()
	level_manager.settings = getLevelSettings()
	get_tree().root.add_child(level_manager)
	level_manager.loadLevel()
	queue_free()
	

func getLevelSettings():
	var node = get_node("horizontal/config/container/select_gamemode/OptionButton")
	var game_mode = node.get_item_text(node.selected)
	node = get_node("horizontal/config/container/select_gamemode/OptionButton")
	var level_name = node.get_item_text(node.selected)

	var settings = {
		level = {
				name = level_name,
				mode = game_mode,
			}
		}
	return settings

