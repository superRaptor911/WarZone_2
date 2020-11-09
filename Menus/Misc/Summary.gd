extends CanvasLayer

func _ready():
	var map = game_states.match_result.map
	var kills = game_states.match_result.kills
	var deaths = game_states.match_result.deaths
	
	setSummary(map, kills, deaths)	
	MenuManager.connect("back_pressed", self,"_on_Ok_pressed")
	MenuManager.admob.show_interstitial()
	MenuManager.admob.show_banner()


func setSummary(map, kills, deaths):
	$Panel/VBoxContainer/deaths/Panel/Label.text = String(deaths)
	$Panel/VBoxContainer/kills/Panel/Label.text = String(kills)
	$Panel/VBoxContainer/map/Panel/Label.text = map



func _on_Ok_pressed():
	MusicMan.click()
	MenuManager.changeScene("mainMenu")


func _on_Timer_timeout():
	MenuManager.changeScene("mainMenu")

