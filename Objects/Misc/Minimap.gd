extends TextureRect

export var cell_size : int = 8


var local_player = null
var ref_pos : Vector2
var Scale : Vector2
var worldsize : Vector2

var dotsList = Array()

func _ready():
	var lvls = get_tree().get_nodes_in_group("Level")
	assert(lvls.size() == 1, "Multiple levels loaded for minimap generation")
	
	if not lvls.empty():
		var lvl = lvls[0]
		var hmap = lvl.get_node("BaseMap/height")
		Scale = Vector2(cell_size,cell_size) / hmap.cell_size
		worldsize = hmap.get_used_rect().size * hmap.cell_size
		var lvl_author = lvl.get("author")
		loadMinimap(lvl.Level_Name, lvl_author)
		getLocalPlayer()
		_cacheDots()
	else:
		print("Error : No level loaded for minimap generation")


func loadMinimap(levl_name : String, level_author):
	if level_author == "INC":
		texture = load("res://Maps/" + levl_name +"/minimap.png")
	elif level_author == String(OS.get_unique_id()) or level_author == null:
		var img = Image.new()
		img.load("user://custom_maps/minimaps/" + levl_name + ".png")
		var img_tex = ImageTexture.new()
		img_tex.create_from_image(img)
		texture = img_tex
	else:
		var img = Image.new()
		img.load("user://downloads/" + level_author + "/custom_maps/minimaps/" + levl_name + ".png")
		var img_tex = ImageTexture.new()
		img_tex.create_from_image(img)
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


func showPlayersInMap():
	if local_player:
		#hide all the dots
		for i in dotsList:
			i.hide()
		
		var sp_index = 0
		for u in game_server._unit_data_list:
			var i = game_server._unit_data_list[u].ref
			if i.alive:
				var rel_pos = (i.position - ref_pos) * Scale
				if rel_pos.x > 0 && rel_pos.y > 0 && rel_pos.x < rect_size.x && rel_pos.y < rect_size.y:
					if i == local_player:
						dotsList[sp_index].modulate = Color8(255,255,255,255)
					elif i.team.team_id == local_player.team.team_id:
						dotsList[sp_index].modulate = Color8(50,255,50,255)
					else:
						dotsList[sp_index].modulate = Color8(255,50,50,255)
					if i.team.team_id == 0  and i.is_in_group("bomber"):
						dotsList[sp_index].modulate = Color8(255,165,0,255)
					dotsList[sp_index].show()
					dotsList[sp_index].position = rel_pos
					sp_index += 1
					if sp_index >= 12:
						break



func _cacheDots():
	dotsList = get_children()


func getLocalPlayer():
	for i in game_server._unit_data_list:
		var p = game_server._unit_data_list[i].ref
		if p.is_network_master() and p.is_in_group("User"):
			local_player = p
			break
