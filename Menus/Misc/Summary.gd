extends CanvasLayer

func _ready():
	var map = game_states.last_match_result.map
	var kills = game_states.last_match_result.kills
	var deaths = game_states.last_match_result.deaths
	var cash = game_states.last_match_result.cash
	var xp = game_states.last_match_result.xp
	
	setSummary(map,kills,deaths,cash,xp)
	game_states.player_data.cash += cash
	game_states.player_data.kills += kills
	game_states.player_data.deaths += deaths


func setSummary(map,kills,deaths,cash,xp):
	$Panel/VBoxContainer/cash/Panel/Label.text = "$" + String(cash)
	$Panel/VBoxContainer/deaths/Panel/Label.text = String(deaths)
	$Panel/VBoxContainer/kills/Panel/Label.text = String(kills)
	$Panel/VBoxContainer/map/Panel/Label.text = map
	$Panel/VBoxContainer/xp/Panel/Label.text = String(xp)


func _on_Ok_pressed():
	print("pressed")
	MenuManager.changeScene("mainMenu")


func _on_Timer_timeout():
	MenuManager.changeScene("mainMenu")
