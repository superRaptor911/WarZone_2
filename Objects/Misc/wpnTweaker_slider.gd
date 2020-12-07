extends Label

onready var hslider 	= get_node("HSlider")
onready var edit_val 	= get_node("Editval") 

signal value_changed

func _ready():
	hslider.connect("value_changed" , self, "on_hslider_val_changed")
	edit_val.connect("text_entered", self, "on_text_entered")
	on_hslider_val_changed(hslider.value)


func on_hslider_val_changed(value):
	edit_val.text = String(value)
	emit_signal("value_changed")
	


func on_text_entered(text):
	hslider.value = float(text)
