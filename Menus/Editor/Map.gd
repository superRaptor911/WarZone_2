extends Node2D

onready var camera = $Camera2D
onready var size = get_viewport_rect().size
onready var parent = get_parent()

onready var ground = $BaseMap
onready var walls = $BaseMap/height

var repeat_factor = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	print(size)


func _draw():
	var LINE_COLOR = Color(255, 255, 255)
	var LINE_WIDTH = 2
	var window_size = OS.get_window_size()

	for x in range(size.x / 64 * repeat_factor):
		var col_pos = x * 64
		var limit = size.y * repeat_factor
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
	for y in range(size.y / 64 * repeat_factor):
		var row_pos = y * 64
		var limit = size.x * repeat_factor
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)


func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			var pos = event.position + camera.position
			pos = Vector2(int(pos.x / 64), int(pos.y / 64))
			fillTile(pos)


func fillTile(pos):
	if parent.selected_tile:
		if parent.selected_tile.is_Wall:
			walls.set_cell(pos.x, pos.y, parent.selected_tile.tile_id,false,
				false,false, parent.selected_tile.auto_tile_coord)
		else:
			ground.set_cell(pos.x, pos.y, parent.selected_tile.tile_id,false,
				false,false, parent.selected_tile.auto_tile_coord)
