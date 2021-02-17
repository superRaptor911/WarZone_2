extends Node

onready var level = get_tree().get_nodes_in_group("Levels")[0]

func _ready():
	createTeams()



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


