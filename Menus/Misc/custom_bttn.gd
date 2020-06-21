extends Button


signal pressed_id(id)

func _ready():
	text = String(int(name) - 1) + ".txt"
	connect("pressed", self, "_on_pressed")


func _on_pressed():
	emit_signal("pressed_id",int(name) - 1)
