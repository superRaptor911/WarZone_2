extends Sprite

var team_id = 0
var red_circle = preload("res://Menus/Editor/T_icon.png")
var blue_circle = preload("res://Menus/Editor/CT_icon.png")

signal selected(spawn_point)


func setTeamID(id):
	if team_id != id:
		team_id = id
		if id == 0:
			texture = red_circle
		else:
			texture = blue_circle



func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			if (event.position - position).length() < 100:
				emit_signal("selected", self)


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			print("xxxxxx")
			emit_signal("selected", self)


func _draw():
	draw_circle(Vector2(0,0), 100, Color8(0,192,250,110))
