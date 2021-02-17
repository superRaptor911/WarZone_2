extends Node

onready var level = get_tree().get_nodes_in_group("Levels")[0]


func _ready():
	createTeams()
	loadTeamSelector()


func createTeams():
	var team = load("res://scripts/general/Team.gd")
	var terrorist = team.new()
	var counter_terrorist = team.new()

	terrorist.team_id   = 0
	terrorist.name      = "team_Terrorist"
	terrorist.team_name = "Terrorist"
	
	counter_terrorist.team_id   = 0
	counter_terrorist.name      = "team_CounterTerrorist"
	counter_terrorist.team_name = "Counter Terrorist"

	level.call_deferred("add_child",terrorist)
	level.call_deferred("add_child",counter_terrorist)



func loadTeamSelector():
	var team_select = load("res://objects/game_modes/tdm/Tdm_select_team.tscn").instance()
	level.call_deferred("add_child",team_select)
