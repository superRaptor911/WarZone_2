extends CanvasLayer

var skins = Array()
var cur_skin_id = 0


func _ready():
	$cash.text = "$" + String(game_states.player_data.cash)
	loadSkins()
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func loadSkins():
	var skns = game_states.skinStats.values()
	for i in skns:
		skins.append(i)
	
	cur_skin_id = 0
	setSkinData()
	

func setSkinData():
	$Panel/portrait/img.texture = game_states.skinResource[skins[cur_skin_id].id]
	$Panel/portrait/Label.text = skins[cur_skin_id].name
	#$Panel/desc/desc.text = skins[cur_skin_id].model_desc
	var team = "Terrorist"
	if skins[cur_skin_id].team_id == 1:
		team = "Counter Terrorist"
	
	$Panel/desc/desc2.text = "Team : " + team
	$Panel/desc/desc2.text += "\nPrice : " + String(skins[cur_skin_id].cost)
	
	$Panel/purchase.disabled = false
	for i in game_states.player_data.skins:
		if i == skins[cur_skin_id].id:
			$Panel/purchase.disabled = true
			break


func _on_purchase_pressed():
	if  skins[cur_skin_id].cost <= game_states.player_data.cash:
		game_states.player_data.cash -= skins[cur_skin_id].cost
		MusicMan.click()
		game_states.player_data.skins.append(skins[cur_skin_id].id)
		$cash.text = "$" + String(game_states.player_data.cash)
		$Panel/purchase.disabled = true


func _on_nextButton_pressed():
	if cur_skin_id < skins.size() - 1:
		MusicMan.click()
		cur_skin_id += 1
		setSkinData()


func _on_prevButton_pressed():
	if cur_skin_id > 0:
		MusicMan.click()
		cur_skin_id -= 1
		setSkinData()


func _on_back_pressed():
	MusicMan.click()
	game_states.savePlayerData()
	MenuManager.changeScene("storeMenu")
	queue_free()
