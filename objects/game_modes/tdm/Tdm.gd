extends Node

onready var level = get_tree().get_nodes_in_group("Levels")[0]


func _ready():
	createTeams()
	loadTeamSelector()
	level.connect("scripts_loaded", self, "loadSkins")


func createTeams():
	var team = load("res://scripts/general/Team.gd")
	var terrorist = team.new()
	var counter_terrorist = team.new()

	terrorist.team_id   = 0
	terrorist.name      = "team_Terrorist"
	terrorist.team_name = "Terrorist"
	
	counter_terrorist.team_id   = 1
	counter_terrorist.name      = "team_CounterTerrorist"
	counter_terrorist.team_name = "Counter Terrorist"

	level.call_deferred("add_child",terrorist)
	level.call_deferred("add_child",counter_terrorist)



func loadTeamSelector():
	var team_select = load("res://objects/game_modes/tdm/Tdm_select_team.tscn").instance()
	level.call_deferred("add_child",team_select)


func loadSkins():
	var tskins = [
		load("res://resources/sprites/characters/t1.bmp"),
		load("res://resources/sprites/characters/t2.bmp"),
		load("res://resources/sprites/characters/t3.bmp"),
		]
	var ctskins = [
		load("res://resources/sprites/characters/ct1.bmp"),
		load("res://resources/sprites/characters/ct2.bmp"),
		load("res://resources/sprites/characters/ct3.bmp"),
		]
	var resource = get_tree().root.get_node("Resources")
	resource.skins.append(tskins) 
	resource.skins.append(ctskins) 
