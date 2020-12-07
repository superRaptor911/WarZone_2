extends CanvasLayer


func _ready():
	$LangSelector.show()
	$LangSelector.connect("lang_changed", $LangSelector, "hide")
	game_states.game_status.is_lang_set = true
	game_states.save_data("user://status.dat",game_states.game_status, false)


func _on_LineEdit_text_entered(new_text):
	game_states.player_data.name = new_text
	game_states.player_info.name = new_text
	
	if new_text != "":
		_on_Button_pressed()


func _on_Button_pressed():
	game_states.savePlayerData()
	MenuManager.changeScene("mainMenu")
