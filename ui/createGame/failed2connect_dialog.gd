extends Panel

onready var ok_btn : Button = get_node("ok_button")

func _ready():
	hide()
	ok_btn.connect("pressed", self, "_on_ok_pressed")


func _on_ok_pressed():
	hide()
