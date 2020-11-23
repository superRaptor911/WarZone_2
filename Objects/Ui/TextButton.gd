extends Button

export var value = "button 1"
signal pressed_text

func _ready():
	connect("pressed", self, "_on_TextButton_pressed")

func _on_TextButton_pressed():
	emit_signal("pressed_text", value)


func _on_en_pressed_text():
	pass # Replace with function body.
