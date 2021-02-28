tool
extends Node2D

export var team_id : int        = 0
export var spawn_radius : float = 100


func _ready():
	update()

func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(0,0), spawn_radius, Color8(0,0,100, 100))


func _on_radius_changed(val):
	spawn_radius = val
	print("Val changed")
	update()
