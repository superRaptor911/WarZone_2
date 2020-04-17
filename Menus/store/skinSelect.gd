extends CanvasLayer


var t_skins = Array()
var ct_skins = Array()

var cur_t_skin = 0
var cur_ct_skin = 0

func _ready():
	loadSkins()

func loadSkins():
	for i in game_states.player_data.skins:
		var skin = game_states.modelResource.get(i).instance()
		if skin.team_id == 0:
			t_skins.append(skin)
		else:
			ct_skins.append(skin)
	
	var index = 0
	for i in t_skins:
		if i.model_name == game_states.player_data.t_model:
			cur_t_skin = index
			break
		index += 1
	
	index = 0
	for i in ct_skins:
		if i.model_name == game_states.player_data.t_model:
			cur_ct_skin = index
			break
		index += 1
		
	selectCtSkin()
	selectTskin()
	

func selectCtSkin():
	$CT/portrait/TextureRect.texture = ct_skins[cur_ct_skin].get_node("skin").texture
	$CT/portrait/label.text = ct_skins[cur_ct_skin].model_real_name


func selectTskin():
	$T/portrait/TextureRect.texture = t_skins[cur_ct_skin].get_node("skin").texture
	$T/portrait/label.text = t_skins[cur_ct_skin].model_real_name



func _on_CTprev_pressed():
	if cur_ct_skin > 0:
		cur_ct_skin -= 1
		selectCtSkin()


func _on_CTnext_pressed():
	if cur_ct_skin < ct_skins.size() - 1:
		cur_ct_skin += 1
		selectCtSkin()


func _on_Tnext_pressed():
	if cur_t_skin < t_skins.size() - 1:
		cur_t_skin += 1
		selectTskin()


func _on_Tprev_pressed():
	if cur_t_skin > 0:
		cur_t_skin -= 1
		selectTskin()

func saveAll():
	game_states.player_data.t_model = t_skins[cur_t_skin].model_name
	game_states.player_data.ct_model = ct_skins[cur_ct_skin].model_name
	game_states.savePlayerData()


func freeSkins():
	for i in t_skins:
		i.queue_free()
	
	for i in ct_skins:
		i.queue_free()


func _on_Back_pressed():
	saveAll()
	freeSkins()
	get_tree().change_scene("res://Menus/store/store_menu.tscn")
	queue_free()
