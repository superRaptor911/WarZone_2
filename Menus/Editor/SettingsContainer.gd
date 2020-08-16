extends TabContainer

onready var camera = get_parent().get_parent().get_node("Map/Camera2D")
onready var map = get_parent().get_parent().get_node("Map")
onready var base_tileset = get_parent().get_parent().get_node("Map/BaseMap")
onready var height_tileset = get_parent().get_parent().get_node("Map/BaseMap/height")


func _on_drawGrid_toggled(button_pressed):
	map.draw_grid = button_pressed
	map.update()


func _on_zslider_value_changed(value):
	camera.zoom = Vector2(value,value)


func _on_clear_pressed():
	base_tileset.clear()
	height_tileset.clear()
