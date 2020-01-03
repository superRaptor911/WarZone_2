#State that gets nearest Player

extends "res://Objects/custom_scripts/fsm_bot.gd"

#search interval
var search_interval : Timer = Timer.new()
signal player_found

func _ready():
	search_interval.wait_time = 1.5
	search_interval.one_shot = true
	search_interval.connect("timeout",self,"_on_search_interval")
	add_child(search_interval)

func _on_search_interval():
	bot._get_nearest_player()
	#if target is found
	if bot.target:
		emit_signal("player_found")
		print("got player")
	#else research after some time
	else:
		search_interval.start()

func startState():
	is_active = true
	#start searching player
	_on_search_interval()

func stopState():
	is_active = false
	search_interval.stop()

