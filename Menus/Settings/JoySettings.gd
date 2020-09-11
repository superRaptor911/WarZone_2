extends Node2D

var is_selected = false
var seleted_item = null

func _on_joy1_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		print("haha")
		is_selected = event.pressed
		if event.pressed:
			seleted_item = $joy1
			seleted_item.get_node("ColorRect").show()
		else:
			seleted_item.get_node("ColorRect").hide()
			seleted_item = null
			



func _unhandled_input(event):
	if seleted_item and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		seleted_item.position = event.position
