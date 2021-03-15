extends Node

onready var game_mode = get_parent() 
var spawn_manager = null

var timer = Timer.new()
# Will contain player  death_time
var player_data = {}


func _ready():
	add_child(timer)
	_connectSignals()
	timer.start()


func _connectSignals():
	timer.connect("timeout", self, "updateLogic")
	game_mode.connect("gamemode_restart", self, "_on_game_restart")
	Signals.connect("entity_killed", self, "_on_player_killed") 
	Signals.connect("spawnmanger_loaded", self, "_on_spawnmanager_loaded")


func _on_spawnmanager_loaded():
	spawn_manager = get_tree().get_nodes_in_group("Levels")[0].get_node("SpawnManager")


func updateLogic():
	var time_now = OS.get_unix_time()
	for i in player_data:
		var data = player_data.get(i)
		if time_now - data > game_mode.mode_settings.spawn_delay:
			revivePlayer(i)
			player_data.erase(i)


func _on_player_killed(victim_name, _attacker, _wpn):
	player_data[victim_name] = OS.get_unix_time()


func revivePlayer(plr_name : String):
	var plr = Utility.getPlayer(plr_name)
	if plr:
		spawn_manager.reviveEntity(plr_name)
		plr.teleport(spawn_manager.getSpawnPosition(plr.team_id))
	else:
		print("Tdm::Logic::Fatal_Error::failed to find player " + plr_name)


func _on_game_restart():
	player_data = {}
	respawnAll()


func respawnAll():
	print("Tdm::Logic::Respawing all")
	spawn_manager.reviveAllEntity()
	var units = get_tree().get_nodes_in_group("Units")
	for i in units:
		i.teleport(spawn_manager.getSpawnPosition(i.team_id))
