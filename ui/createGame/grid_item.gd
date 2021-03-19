extends TextureButton

signal item_selected(name)

func _ready():
	connect("pressed", self, "_on_pressed")
	get_node("Label").text = name


func _on_pressed():
	print("select asdasdasd")
	modulate = Color8(200, 200, 255, 255)
	emit_signal("item_selected", name)


func unselect():
	modulate = Color.white
