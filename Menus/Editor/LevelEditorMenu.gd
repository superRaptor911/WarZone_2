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


func _on_convert_pressed():
	var levelInfo = {
		name = "Dust II",
		minimap = "",
		game_modes = [
				{bombing = "" },
				{FFA = ""}
			],
		desc = "",
		debug = false
	}
	
	var base_map = null
	var game_modes = [null, null]
	var map_name = game_server.serverInfo.map
	
	var file = File.new()
	var file_name = "user://custom_maps/maps/" + map_name + ".tscn"
	if file.file_exists(file_name):
		base_map = load(file_name).instance()
		base_map.name = "BaseMap"
		base_map.force_update = false
	
	file_name = "user://custom_maps/gameModes/TDM/" + map_name + ".tscn"
	if file.file_exists(file_name):
		game_modes[0] = load(file_name).instance()

	file_name = "user://custom_maps/gameModes/Zombie/" + map_name + ".tscn"
	if file.file_exists(file_name):
		game_modes[1] = load(file_name).instance()
	
	var level_node = Node2D.new()
