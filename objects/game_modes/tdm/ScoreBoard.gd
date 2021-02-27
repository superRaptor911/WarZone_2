extends Control

var score_panel = preload("res://objects/game_modes/tdm/scorepanel.tscn")
onready var t_container = get_node("HBoxContainer/t/VBoxContainer")
onready var ct_container = get_node("HBoxContainer/ct/VBoxContainer")
onready var back_btn : Button = get_node("Button")

func _ready():
	updateScore()
	back_btn.connect("pressed", self, "_on_back_button_pressed")


func updateScore():
	var teams = get_tree().get_nodes_in_group("Teams")
	for team in teams:
		if team.team_id == 0:
			var players = team.players.values()
			for i in players:
				var new_score_panel = score_panel.instance()
				new_score_panel.setScore(i.nick, i.score, i.deaths, i.ping)
				t_container.add_child(new_score_panel)
		else:
			var players = team.players.values()
			for i in players:
				var new_score_panel = score_panel.instance()
				new_score_panel.setScore(i.nick, i.score, i.deaths, i.ping)
				ct_container.add_child(new_score_panel)


func _on_back_button_pressed():
	queue_free()
