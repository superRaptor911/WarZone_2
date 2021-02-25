extends Control

onready var quit_game_btn : Button = get_node("Panel/container/quit_game")
onready var back_btn : Button = get_node("Panel/container/Back")



func _ready():
	_connectSignals()


func _connectSignals():
	quit_game_btn.connect("pressed", self, "_on_quit_game_pressed")
	back_btn.connect("pressed", self, "_on_back_button_pressed")
	


func _on_quit_game_pressed():
	var cleanup_script = load("res://scripts/general/Cleanup.gd").new()
	get_tree().root.add_child(cleanup_script)
	cleanup_script.cleanUP()


func _on_back_button_pressed():
	queue_free()
