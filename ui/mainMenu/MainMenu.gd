extends Control

onready var new_game_button = get_node("links_container/new_game")
onready var settings_button = get_node("links_container/settings")


func _ready():
	_connectSignals()

func _connectSignals():
	new_game_button.connect("pressed", self, "_on_new_game_button_pressed")
	settings_button.connect("pressed", self, "_on_settings_button_pressed")
	UImanager.connect("back_pressed", self, "_on_back_pressed") 

func _on_new_game_button_pressed():
	UImanager.changeMenuTo("new_game")


func _on_settings_button_pressed():
	UImanager.changeMenuTo("settings")


func _on_back_pressed():
	get_tree().quit()
