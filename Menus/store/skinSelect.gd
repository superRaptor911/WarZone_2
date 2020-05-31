extends CanvasLayer


var t_skins = Array()
var ct_skins = Array()

var cur_t_skin = 0
var cur_ct_skin = 0

func _ready():
	loadSkins()
	$Admob.load_banner()

func loadSkins():
	for i in game_states.player_data.skins:
		var skin = game_states.skinResource.get(i)
		if i.begins_with("ct"):
			ct_skins.append([skin,i,game_states.skinStats[i].name])
		else:
			t_skins.append([skin,i,game_states.skinStats[i].name])
	
	var index = 0
	for i in t_skins:
		if i[1] == game_states.player_data.t_model:
			cur_t_skin = index
			break
		index += 1
	
	index = 0
	for i in ct_skins:
		if i[1] == game_states.player_data.t_model:
			cur_ct_skin = index
			break
		index += 1
		
	selectCtSkin()
	selectTskin()
	

func selectCtSkin():
	$CT/portrait/TextureRect.texture = ct_skins[cur_ct_skin][0]
	$CT/portrait/label.text = ct_skins[cur_ct_skin][2]


func selectTskin():
	$T/portrait/TextureRect.texture = t_skins[cur_t_skin][0]
	$T/portrait/label.text = t_skins[cur_t_skin][2]




func _on_CTprev_pressed():
	if cur_ct_skin > 0:
		MusicMan.click()
		cur_ct_skin -= 1
		selectCtSkin()


func _on_CTnext_pressed():
	if cur_ct_skin < ct_skins.size() - 1:
		MusicMan.click()
		cur_ct_skin += 1
		selectCtSkin()


func _on_Tnext_pressed():
	if cur_t_skin < t_skins.size() - 1:
		MusicMan.click()
		cur_t_skin += 1
		selectTskin()


func _on_Tprev_pressed():
	if cur_t_skin > 0:
		MusicMan.click()
		cur_t_skin -= 1
		selectTskin()

func saveAll():
	game_states.player_data.t_model = t_skins[cur_t_skin][1]
	game_states.player_data.ct_model = ct_skins[cur_ct_skin][1]
	game_states.savePlayerData()




func _on_Back_pressed():
	MusicMan.click()
	saveAll()
	MenuManager.changeScene("storeMenu")
	queue_free()
