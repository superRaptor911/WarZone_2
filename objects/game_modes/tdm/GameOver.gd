extends CanvasLayer

onready var timer = get_node("Timer") 
onready var container = get_node("Panel/VBoxContainer") 
onready var time_left_label = get_node("Panel2/time_left") 

signal restart_gamemode

var time_left : int = 5


func _ready():
	_connectSignals()
	timer.start()
	showWinners()


func _connectSignals():
	timer.connect("timeout", self, "_on_timeout")


func _on_timeout():
	time_left -= 1
	time_left_label.text = "New Game in ... %d" % [time_left]
	# Restart timer
	if time_left != 0:
		timer.start()
	else:
		emit_signal("restart_gamemode")
		queue_free()


class MyCustomSorter:
	static func sort_ascending(a, b):
		if a.kills < b.kills:
			return true
		return false


func showWinners():
	var teams = get_tree().get_nodes_in_group("Teams")
	var top_3 = []
	for i in teams:
		var players = i.players.values()
		for p in players:
			if top_3.size() < 3:
				top_3.append({ name = p.name, kills = p.kills })
				top_3.sort_custom(MyCustomSorter, "sort_ascending")
			elif top_3[2].kills < p.kills:
				top_3[2] = { name = p.name, kills = p.kills }
				top_3.sort_custom(MyCustomSorter, "sort_ascending")

