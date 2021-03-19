extends Control

onready var start_game : Button = get_node("config/start")
onready var level_options = get_node("config/container/select_level/select")
onready var mode_options : OptionButton = get_node("config/container/select_gamemode/OptionButton")

var level_selector_scene = preload("res://ui/createGame/LevelSelector.tscn")
var level_reader = preload("res://ui/createGame/LevelReader.gd").new()
var network = null

func _ready():
	add_child(level_reader)
	_connectSignals()
	_fillLevels()


func _connectSignals():
	start_game.connect("pressed", self, "_on_start_pressed")
	level_options.connect("pressed", self, "_on_level_pressed")
	UImanager.connect("back_pressed", self, "_on_back_pressed") 


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
	var node = get_node("config/container/select_gamemode/OptionButton")
	var game_mode = node.get_item_text(node.selected)
	node = get_node("config/container/select_level/selected")
	var level_name = node.get_item_text(node.selected)

	var settings = {
		level = {
				name = level_name,
				mode = game_mode,
			}
		}
	return settings


func _fillLevels():
	var levels = level_reader.getLevels()
	# Select first level
	if !levels.empty():
		_on_level_selected(levels[0])


func _on_level_selected(level):
	level_options.text = level
	var modes = level_reader.getLevelModes(level)
	mode_options.clear()
	for i in modes:
		mode_options.add_item(i)


func _on_level_pressed():
	var level_selector = level_selector_scene.instance()
	level_selector.connect("level_selected", self, "_on_level_selected") 
	add_child(level_selector)


func _on_back_pressed():
	UImanager.changeMenuTo("main_menu")
