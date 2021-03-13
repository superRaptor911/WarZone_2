extends Node

onready var game_mode = get_parent() 

var timer = Timer.new()
# Will contain player name, death_time
var player_data = {}


func _ready():
	add_child(timer)
	_connectSignals()
	timer.start()


func _connectSignals():
	timer.connect("timeout", self, "updateLogic")


func updateLogic():
	var time_now = OS.get_unix_time()
	for i in player_data:
		var data = player_data.get(i)
		if time_now - data.death_time > game_mode.mode_settings.spawn_delay:
			player_data.erase(i)
