extends Control

onready var create_server : Button = get_node("container/create_server")

func _ready():
	_connectSignals()

func _connectSignals():
	create_server.connect("pressed", self, "_on_create_server_pressed")


func _on_create_server_pressed():
	UImanager.changeMenuTo("create_game")

