extends TextureRect

var user
var zoom
var level
var cell_size
var offset : Vector2
var top_t_pos : Vector2
var bottom_t_pos : Vector2

var grid  = Array()

func _ready():
	_get_user()
	_get_level()
	_get_t_pos()
	update()


func _setup_grid():
	pass

func _get_t_pos():
	var tp = user.get_node("Camera2D").global_position
	print(tp)
	
	var bp = tp + get_viewport().size * zoom
	
	top_t_pos = level.world_to_map(tp)
	bottom_t_pos = level.world_to_map(bp)
	print(level.map_to_world(top_t_pos).x)
	offset.x = tp.x - level.map_to_world(top_t_pos).x
	offset.y = cell_size.y - (int(tp.y)  % int(cell_size.y))

func _get_user():
	var players = get_tree().get_nodes_in_group("User")
	for p in players:
		if p.is_network_master():
			user = p
			break
	zoom = user.selected_gun.current_zoom

func _get_level():
	var levels = get_tree().get_nodes_in_group("Level")
	level = levels[0]
	cell_size = level.cell_size

func _draw():
	for i in range(top_t_pos.x,bottom_t_pos.x):
		var true_pos = (level.map_to_world(Vector2(i,top_t_pos.y)) + offset)/ zoom
		var true_pos2 = (level.map_to_world(Vector2(i,bottom_t_pos.y)) + offset)/ zoom
		draw_line(true_pos, true_pos2, Color(255, 0, 0), 1)

func _on_quit_pressed():
	get_tree().root.add_child(load("res://Menus/Inventory/turret_menu.tscn").instance())
	queue_free()
