extends CanvasLayer

func _ready():
	$Panel/VBoxContainer/cash/Panel/Label.text = "$" + String(game_states.player_data.cash)
	$Panel/VBoxContainer/deaths/Panel/Label.text = String(game_states.player_data.deaths)
	$Panel/VBoxContainer/kills/Panel/Label.text = String(game_states.player_data.kills)
	$Panel/VBoxContainer/name/LineEdit.text = game_states.player_data.name
	$Panel/VBoxContainer/Level/Panel/Label.text = String(game_states.getLevelFromXP(game_states.player_data.XP))


func _on_back_pressed():
	game_states.player_data.name = $Panel/VBoxContainer/name/LineEdit.text
	game_states.savePlayerData()
	MenuManager.changeScene("mainMenu")
