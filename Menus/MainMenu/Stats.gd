extends CanvasLayer


func _ready():
	$Panel/VBoxContainer/cash/Panel/Label.text = "$" + String(game_states.player_data.cash)
	$Panel/VBoxContainer/deaths/Panel/Label.text = String(game_states.player_data.deaths)
	$Panel/VBoxContainer/kills/Panel/Label.text = String(game_states.player_data.kills)
	$Panel/VBoxContainer/name/LineEdit.text = game_states.player_data.name
	$Panel/VBoxContainer/Level/Panel/Label.text = String(game_states.getLevelFromXP(game_states.player_data.XP))
	UiAnim.animLeftToRight([$Panel])
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func _on_back_pressed():
	MusicMan.click()
	game_states.player_data.name = $Panel/VBoxContainer/name/LineEdit.text
	game_states.player_info.name = $Panel/VBoxContainer/name/LineEdit.text
	game_states.savePlayerData()
	UiAnim.animZoomOut([$Panel])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("mainMenu")
