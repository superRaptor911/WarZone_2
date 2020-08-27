extends Node2D

onready var camera = $Camera2D
onready var size = get_viewport_rect().size
onready var editor = get_parent()

onready var minimap = editor.get_node("UILayer/minimap")
onready var viewport = get_node("Viewport")
onready var viewport_cam = get_node("Viewport/Camera2D")

onready var ground = $BaseMap
onready var walls = $BaseMap/height

var draw_grid = true
var draw_selection_rect = false
var repeat_factor = 2


var was_pressed = false
var press_pos = Vector2()
var cur_pos = Vector2()

func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		was_pressed = event.pressed	
		if event.pressed:
			press_pos = event.position
			handlePressOperation(event)
		else:
			handleReleaseOperation(event)
	elif event is InputEventScreenDrag or ((event is InputEventMouseMotion) and was_pressed):
		handleDragOperation(event)


func handlePressOperation(event):
	var pos = (event.position + camera.position / camera.zoom)
	pos = Vector2(int(pos.x / (64 / camera.zoom.x) ), int(pos.y / (64 / camera.zoom.x)))
	
	if editor.current_tool == editor.TOOLS.PEN:
		fillTile(pos)
	elif editor.current_tool == editor.TOOLS.RUBBER:
		removeTile(pos)
	elif editor.current_tool == editor.TOOLS.PICKER:
		pickTile(pos)


func handleReleaseOperation(event):
	if editor.current_tool == editor.TOOLS.AREA:
		areaFillTile(event)


func handleDragOperation(event):
	var pos = (event.position + camera.position / camera.zoom)
	pos = Vector2(int(pos.x / (64 / camera.zoom.x) ), int(pos.y / (64 / camera.zoom.x)))
	
	if editor.current_tool == editor.TOOLS.PEN:
		fillTile(pos)
	elif editor.current_tool == editor.TOOLS.RUBBER:
		removeTile(pos)
	elif editor.current_tool == editor.TOOLS.AREA:
		draw_selection_rect = true
		cur_pos = event.position
		update()


func fillTile(pos):
	if pos.x < 0 or pos.y < 0:
		return
	if editor.selected_tile:
		if editor.selected_tile.is_Wall:
			walls.set_cell(pos.x, pos.y, editor.selected_tile.tile_id,false,
				false,false, editor.selected_tile.auto_tile_coord)
		else:
			walls.set_cell(pos.x, pos.y, -1)
			ground.set_cell(pos.x, pos.y, editor.selected_tile.tile_id,false,
				false,false, editor.selected_tile.auto_tile_coord)


func removeTile(pos):
	if pos.x < 0 or pos.y < 0:
		return
	walls.set_cellv(pos,-1)
	ground.set_cellv(pos,-1)


func areaFillTile(event):
	draw_selection_rect = false
	update()
	for i in range(press_pos.x, event.position.x, sign(event.position.x - press_pos.x)):
		for j in range(press_pos.y, event.position.y, sign(event.position.y - press_pos.y)):
			var pos = (Vector2(i , j) + camera.position / camera.zoom)
			pos = Vector2(int(pos.x / (64 / camera.zoom.x) ), int(pos.y / (64 / camera.zoom.x)))
			fillTile(pos)


func pickTile(pos):
	if pos.x < 0 or pos.y < 0:
		return
	if walls.get_cellv(pos) != -1:
		var tid = walls.get_cellv(pos)
		var coord = walls.get_cell_autotile_coord(pos.x, pos.y)
		var tiles = editor.get_node("UILayer/TileTabContainer/Walls/grid").get_children()
		
		for i in tiles:
			if i.tile_id == tid and i.auto_tile_coord == coord:
				editor.selected_tile = i
				return
	elif ground.get_cellv(pos) != -1:
		var tid = ground.get_cellv(pos)
		var coord = ground.get_cell_autotile_coord(pos.x, pos.y)
		var tiles = editor.get_node("UILayer/TileTabContainer/ground/grid").get_children()
		
		for i in tiles:
			if i.tile_id == tid and i.auto_tile_coord == coord:
				editor.selected_tile = i
				return
	

func _on_minimap_update_timer_timeout():
	var map = $BaseMap
	remove_child(map)
	viewport.add_child(map)
	map.set_owner(viewport)
	viewport_cam.position = camera.position
	
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	#yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	var img = viewport.get_texture().get_data()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	minimap.texture = tex
	
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = Viewport.UPDATE_DISABLED
	
	viewport.remove_child(map)
	add_child(map)
	map.set_owner(self)


func _draw():
	if draw_grid:
		var LINE_COLOR = Color(255, 255, 255)
		var LINE_WIDTH = 1
		#var window_size = OS.get_window_size()
	
		for x in range(editor.map_size.x + 1):
			var col_pos = x * 64
			var limit = editor.map_size.y * 64
			draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
		for y in range(editor.map_size.y + 1):
			var row_pos = y * 64
			var limit = editor.map_size.x * 64
			draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
	
	if draw_selection_rect:
		var pos = (press_pos + camera.position / camera.zoom)
		pos = Vector2(int(pos.x / (64 / camera.zoom.x) ), int(pos.y / (64 / camera.zoom.x))) * 64
		var end = (cur_pos + camera.position / camera.zoom)
		end = Vector2(int(end.x / (64 / camera.zoom.x) ), int(end.y / (64 / camera.zoom.x))) * 64
		if end.x > pos.x:
			end.x += 64
		else:
			pos.x += 64
		if end.y > pos.y:
			end.y += 64
		else:
			pos.y += 64

		var rectSize = (end - pos)
		var rect = Rect2(pos, rectSize)
		draw_rect(rect,Color8(21,38,217,108))
		
