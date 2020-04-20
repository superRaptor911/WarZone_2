extends TextureRect

export var cell_size : int = 8


var local_player = null
var ref_pos : Vector2
var Scale : Vector2
var worldsize : Vector2
var playerList = Array()
var dotsList = Array()

func _ready():
	var lvls = get_tree().get_nodes_in_group("Level")
	if lvls.size() > 1:
		print("Warning : multiple levels loaded for minimap generation")
	if not lvls.empty():
		var lvl = lvls[0]
		var hmap = lvl.get_node("BaseMap/height")
		Scale = Vector2(cell_size,cell_size) / hmap.cell_size
		worldsize = hmap.get_used_rect().size * hmap.cell_size
		print(worldsize)
		createMinimap(hmap.get_used_rect().size,hmap.get_used_cells(),lvl.Level_Name)
		playerList = get_tree().get_nodes_in_group("Unit")
		getLocalPlayer()
		lvl.connect("player_spawned", self,"addPlayer")
		lvl.connect("bot_spawned", self,"addPlayer")
		lvl.connect("player_despawned", self,"removeplayer")
		lvl.connect("bot_despawned", self,"removeplayer")
		_cacheDots()
	else:
		print("Error : No level loaded for minimap generation")


func createMinimap(world_size : Vector2,used_cells : Array, levl_name):
	texture = load("res://Maps/" + levl_name +"/minimap.png")


func createTexture(res : Vector2, levl_name, data : PoolByteArray):
	var image = Image.new()
	var imageTex = ImageTexture.new()
	image.create_from_data(res.x,res.y,false,Image.FORMAT_RGB8,data)
	imageTex.create_from_image(image)
	#save Texture because android cannot use generated texture
	imageTex.get_data().save_png("res://Maps/" + levl_name +"/minimap.png")
	texture = load("res://Maps/" + levl_name +"/minimap.png")

func moveMapWithPlayer():
	if local_player:
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
		for i in playerList:
			var rel_pos = (i.position - ref_pos) * Scale
			if rel_pos.x > 0 && rel_pos.y > 0 && rel_pos.x < rect_size.x && rel_pos.y < rect_size.y:
				if i == local_player:
					dotsList[sp_index].modulate = Color8(255,255,255,255)
				elif i.team.team_id == local_player.team.team_id:
					dotsList[sp_index].modulate = Color8(50,255,50,255)
				else:
					dotsList[sp_index].modulate = Color8(255,50,50,255)
				dotsList[sp_index].show()
				dotsList[sp_index].position = rel_pos
				sp_index += 1
				if sp_index >= 12:
					break

func removeplayer(plr):
	playerList.erase(plr)
	
	
func addPlayer(plr):
	if plr != local_player:
		playerList.append(plr)
	else:
		print("error duplicate")

func _cacheDots():
	dotsList = get_children()

func getLocalPlayer():
	for p in playerList:
		if p.is_network_master() and p.is_in_group("User"):
			local_player = p
			break
