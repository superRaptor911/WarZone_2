extends CanvasLayer

var skins = Array()
var cur_skin_id = 0


func _ready():
	$cash.text = "$" + String(game_states.player_data.cash)
	loadSkins()


func loadSkins():
	var skns = game_states.modelResource.values()
	for i in skns:
		skins.append(i.instance())
	
	cur_skin_id = 0
	setSkinData()
	

func setSkinData():
	$Panel/portrait/img.texture = skins[cur_skin_id].get_node("skin").texture
	$Panel/portrait/Label.text = skins[cur_skin_id].model_real_name
	$Panel/desc/desc.text = skins[cur_skin_id].model_desc
	var team = "Terrorist"
	if skins[cur_skin_id].team_id == 1:
		team = "Counter Terrorist"
	
	$Panel/desc/desc2.text = "Team : " + team
	$Panel/desc/desc2.text += "\nPrice : " + String(skins[cur_skin_id].price)
	
	$Panel/purchase.disabled = false
	for i in game_states.player_data.skins:
		if i == skins[cur_skin_id].model_name:
			$Panel/purchase.disabled = true
			break


func freeSkins():
	for i in skins:
		i.queue_free()


func _on_purchase_pressed():
	if  skins[cur_skin_id].price < game_states.player_data.cash:
		game_states.player_data.skins.append(skins[cur_skin_id].model_name)
		$cash.text = "$" + String(game_states.player_data.cash)
		$Panel/purchase.disabled = true


func _on_nextButton_pressed():
	if cur_skin_id < skins.size() - 1:
		cur_skin_id += 1
		setSkinData()


func _on_prevButton_pressed():
	if cur_skin_id > 0:
		cur_skin_id -= 1
		setSkinData()


func _on_back_pressed():
	game_states.savePlayerData()
	freeSkins()
	MenuManager.changeScene("storeMenu")
	queue_free()
