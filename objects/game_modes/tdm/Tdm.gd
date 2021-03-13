extends Node

onready var level = get_tree().get_nodes_in_group("Levels")[0]

# var limiter_script = null

var mode_settings = {
		time_limit = 5,
		frag_limit = 50,

		spawn_delay = 5,
	}

func _ready():
	createTeams()
	loadTeamSelector()
	loadServerScripts()
	level.connect("resources_loaded", self, "_on_resource_file_loaded")


func loadServerScripts():
	if get_tree().is_network_server():
		var limiter_script = load("res://objects/game_modes/tdm/Limiter.gd").new()
		var death_man = load("res://objects/game_modes/tdm/DeathManager.gd").new()
		var tdm_logic = load("res://objects/game_modes/tdm/Tdm_Logic.gd").new()
		add_child(limiter_script)
		add_child(death_man)
		add_child(tdm_logic)
		limiter_script.connect("timelimit_over", self, "_on_game_over") 
		limiter_script.connect("scorelimit_over", self, "_on_game_over") 



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


func _on_resource_file_loaded():
	loadSkins()
	# loadScoreboard()


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


func loadScoreboard():
	var scoreboard = load("res://objects/game_modes/tdm/ScoreBoard.tscn")
	var resource = get_tree().root.get_node("Resources")
	resource.scoreboard = scoreboard


func _on_game_over():
	rpc("C_onGameOver")


func loadGameOverMenu():
	var game_over = load("res://objects/game_modes/tdm/GameOver.tscn").instance()
	add_child(game_over)
	if get_tree().is_network_server():
		game_over.connect("restart_gamemode", self, "restartGameMode")


# ............................Networking .............................................

remotesync func C_onGameOver():
	loadGameOverMenu()



