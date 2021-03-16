extends Control

onready var quit_game_btn : Button = get_node("Panel/container/quit_game")
onready var back_btn : Button = get_node("Panel/container/Back")
onready var scoreboard : Button = get_node("Panel/container/scoreboard")



func _ready():
	_connectSignals()


func _connectSignals():
	quit_game_btn.connect("pressed", self, "_on_quit_game_pressed")
	back_btn.connect("pressed", self, "_on_back_button_pressed")
	scoreboard.connect("pressed", self, "_on_scoreboard_pressed")
	UImanager.connect("back_pressed", self, "queue_free") 
	


func _on_quit_game_pressed():
	var cleanup_script = load("res://scripts/general/Cleanup.gd").new()
	get_tree().root.add_child(cleanup_script)
	cleanup_script.cleanUP()


func _on_back_button_pressed():
	queue_free()



func _on_scoreboard_pressed():
	var resource = get_tree().root.get_node("Resources")
	var score_board = resource.scoreboard.instance()
	get_parent().add_child(score_board)
	queue_free()
