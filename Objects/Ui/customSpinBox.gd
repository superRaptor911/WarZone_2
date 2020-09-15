class_name CustomSpinButton
extends Label


export var value = 0.0
export var max_value = 100.0
export var min_value = 0.0
export var increment = 1.0

func _ready():
	text = String(value)

func _on_up_pressed():
	value = max(min(value + increment, max_value), min_value)
	text = String(value)


func _on_down_pressed():
	value = max(min(value, max_value) - increment, min_value)
	text = String(value)
