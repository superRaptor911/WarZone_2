extends CanvasLayer

func _ready():
	$PanelContainer/Panel/pname.text = game_states.player_info.name


func _on_ok_pressed():
	game_states.save_player_info()
	get_tree().change_scene("res://Menus/Settings/Settings.tscn")


func _on_pname_text_changed(new_text):
	game_states.player_info.name = new_text
