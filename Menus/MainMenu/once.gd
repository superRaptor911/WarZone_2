extends CanvasLayer


func _on_Button_pressed():
	game_states.savePlayerData()
	MenuManager.changeScene("mainMenu")


func _on_LineEdit_text_entered(new_text):
	game_states.player_data.name = new_text
	game_states.player_info.name = new_text

	if not (new_text == ""):
		_on_Button_pressed()
