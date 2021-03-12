extends CanvasLayer

onready var timer = get_node("Timer") 
onready var container = get_node("Panel/VBoxContainer") 
onready var time_left_label = get_node("Panel2/time_left") 

var time_left : int = 5


func _ready():
	_connectSignals()
	timer.start()


func _connectSignals():
	timer.connect("timeout", self, "_on_timeout")


func _on_timeout():
	time_left -= 1
	time_left_label.text = "New Game in ... %d" % [time_left]
	# Restart timer
	if time_left != 0:
		timer.start()
	else:
		queue_free()

