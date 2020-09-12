extends Control

var is_selected = false
var seleted_item = null
var radius = [90,90]

onready var joy1 = $j1
onready var joy2 = $j2

signal controller_selected



func _ready():
	connect("controller_selected", self, "on_joy_selected")


func _on_j1_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		is_selected = event.pressed
		if event.pressed:
			if seleted_item:
				seleted_item.get_node("ColorRect").hide()
			seleted_item = $j1
			seleted_item.get_node("ColorRect").show()
			emit_signal("controller_selected")

	elif seleted_item == joy1 and is_selected and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		seleted_item.rect_position += event.relative



func _on_j2_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		is_selected = event.pressed
		if event.pressed:
			if seleted_item:
				seleted_item.get_node("ColorRect").hide()
			seleted_item = $j2
			seleted_item.get_node("ColorRect").show()
			emit_signal("controller_selected")
	
	elif seleted_item == joy2 and is_selected and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		seleted_item.rect_position += event.relative


func on_joy_selected():
	$settings.show()
	$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
	$settings/inner_ring.max_value = seleted_item.rect_size.x
	$settings/out_ring.value = seleted_item.rect_size.x
	$settings/inner_ring.value = seleted_item.get_node("j2").rect_size.x
	#var radius = $settings/radius.value
	#seleted_item.get_node("ColorRect").rect_size = Vector2(radius, radius)



func _on_out_ring_value_changed(value):
	if seleted_item:
		seleted_item.rect_size = Vector2(value, value)
		$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
		$settings/inner_ring.max_value = seleted_item.rect_size.x
		var inner_ring = seleted_item.get_node("j2")
		inner_ring.rect_position = seleted_item.rect_size / 2 - inner_ring.rect_size / 2
		seleted_item.get_node("ColorRect").rect_size = seleted_item.rect_size


func _on_inner_ring_value_changed(value):
	if seleted_item:
		seleted_item.get_node("j2").rect_size = Vector2(value, value)
		$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
		$settings/inner_ring.max_value = seleted_item.rect_size.x
		var inner_ring = seleted_item.get_node("j2")
		inner_ring.rect_position = seleted_item.rect_size / 2 - inner_ring.rect_size / 2


func _on_radius_value_changed(value):
	if seleted_item:
		var pos = seleted_item.rect_size / 2 - seleted_item.get_node("j2").rect_size / 2
		var fpos = pos - Vector2(0, seleted_item.rect_size.x / 2) * value / 100.0 
		seleted_item.get_node("j2").rect_position = fpos
