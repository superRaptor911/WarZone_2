extends TextureRect

export var cell_size : int = 8

var local_player = null
var ref_pos : Vector2
var Scale : Vector2
var worldsize : Vector2

func _ready():
	var lvl = get_tree().get_nodes_in_group("Level")[0]
	var map = lvl.get_node("BaseMap")
	Scale = Vector2(cell_size,cell_size) / map.cell_size
	worldsize = (map.get_used_rect().size + map.get_used_rect().position)* map.cell_size
	var lvl_author = lvl.get("author")
	loadMinimap(lvl.Level_Name, lvl_author)
	getLocalPlayer()
	
	rect_size.x = min(rect_size.x, worldsize.x / 8)
	rect_size.y = min(rect_size.y, worldsize.y / 8)


func loadMinimap(levl_name : String, level_author):
	if level_author == "INC":
		texture = load("res://Maps/" + levl_name +"/minimap.png")
		if not texture:
			texture = load("res://Maps/" + levl_name +"/minimaps/" + levl_name +".png")
	elif level_author == String(OS.get_unique_id()) or level_author == null:
		var img = Image.new()
		img.load("user://custom_maps/minimaps/" + levl_name + ".png")
		var img_tex = ImageTexture.new()
		img_tex.create_from_image(img, 0)
		texture = img_tex
	else:
		var img = Image.new()
		img.load("user://downloads/" + level_author + "/custom_maps/minimaps/" + levl_name + ".png")
		var img_tex = ImageTexture.new()
		img_tex.create_from_image(img, 0)
		texture = img_tex


func moveMapWithPlayer():
	if is_instance_valid(local_player):
		var half_res = get_viewport().size / 2
		ref_pos = local_player.position - half_res
		var e = rect_size / Scale
		ref_pos.x = clamp(ref_pos.x,0, worldsize.x - e.x)
		ref_pos.y = clamp(ref_pos.y,0, worldsize.y - e.y)
		material.set_shader_param("pos",ref_pos / worldsize)
	else:
		getLocalPlayer()


func getLocalPlayer():
	for i in game_server._unit_data_list:
		var p = game_server._unit_data_list[i].ref
		if p.is_network_master() and p.is_in_group("User"):
			local_player = p
			break
