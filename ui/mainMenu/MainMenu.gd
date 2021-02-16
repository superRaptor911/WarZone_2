extends Control

onready var new_game_button = get_node("links_container/new_game")


func _ready():
	_connectSignals()

func _connectSignals():
	new_game_button.connect("pressed", self, "_on_new_game_button_pressed")

func _on_new_game_button_pressed():
	UImanager.changeMenuTo("new_game")
