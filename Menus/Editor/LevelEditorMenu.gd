extends Control

func _ready():
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_mapEditor_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LEM/LevelEditor")


func _on_gameMode_pressed():
	var file = File.new()
	var file_name = "user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn"
	
	if file.file_exists(file_name):
		MusicMan.click()
		MenuManager.changeScene("EMS/LEM/GameModesMenu")
	else:
		Logger.notice.showNotice(self, "Error", "You need to create a level first.", Color.red)



func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("EditorMapSelector")
