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
	pass
