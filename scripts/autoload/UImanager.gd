extends Node

var menus = {
	main_menu = "res://ui/mainMenu/MainMenu.tscn",
	new_game  = "res://ui/newGame/NewGame.tscn"
}


func changeMenuTO(menu_name : String):
	var scene_path = menus.get(menu_name)
	if scene_path:
		get_tree().change_scene(scene_path)
	else:
		print("UImanager::Error::unable to find scene " + menu_name)
