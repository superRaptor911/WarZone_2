extends Node

var menus = {
	main_menu   = "res://ui/mainMenu/MainMenu.tscn",
	new_game    = "res://ui/newGame/NewGame.tscn",
	create_game = "res://ui/createGame/CreateGame.tscn",
	join_game	= "res://ui/joinGame/JoinGame.tscn",
	settings    = "res://ui/settings/Settings.tscn",
	profile     = "res://ui/profileMenu/ProfileMenu.tscn",
	sound_settings = "res://ui/soundSettings/SoundSettings.tscn",
	display_settings = "res://ui/displaySettings/DisplaySettings.tscn"
}

signal back_pressed

func changeMenuTo(menu_name : String):
	var scene_path = menus.get(menu_name)
	if scene_path:
		get_tree().change_scene(scene_path)
	else:
		print("UImanager::Error::unable to find scene " + menu_name)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Back_pressed()
	elif what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_Back_pressed()


func _on_Back_pressed():
	emit_signal("back_pressed")
