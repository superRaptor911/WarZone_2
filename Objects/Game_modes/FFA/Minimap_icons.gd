extends Control

onready var parent = get_parent()

func _draw():
	for i in parent.draw_data:
		draw_circle(i.p, 2, i.c)
	parent.draw_data.clear()
