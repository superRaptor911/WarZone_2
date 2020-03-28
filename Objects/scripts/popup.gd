extends Control


var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	timer.connect("timeout",self,"_on_timeout")
	add_child(timer)


func popup(sec):
	timer.start(sec)
	show()

func _on_timeout():
	hide()
