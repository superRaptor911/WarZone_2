extends Control

onready var create_server : Button = get_node("container/create_server")
onready var join_server : Button = get_node("container/join_server")

func _ready():
	_connectSignals()

func _connectSignals():
	create_server.connect("pressed", self, "_on_create_server_pressed")
	join_server.connect("pressed", self, "_on_join_server_pressed")


func _on_create_server_pressed():
	UImanager.changeMenuTo("create_game")


func _on_join_server_pressed():
	UImanager.changeMenuTo("join_game")
