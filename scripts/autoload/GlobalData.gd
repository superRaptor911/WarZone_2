extends Node

const path		   = "user://data/"
const game_version = 2.0

var game_status = {
		game_version = 2.0,
		runs = 0
	}

var settings = {
	# Display
		dynamic_cam = true,
		gore        = true,
	
	# Sound
		master_vol = 3,
		music_vol  = 3,
		sfx_vol    = 3
	}


var player_info = {
		nick   = "Warrior<player>",
		kills  = 0,
		deaths = 0
	}

func _ready():
	loadGameStatus()
	loadSettings()
	loadPlayerInfo()
	_applySettings()


func loadGameStatus():
	var data = Utility.loadDictionary(path + "game_status.json")
	if data:
		Utility.dictionaryCpy(game_status, data)
	else:
		var dir = Directory.new()
		dir.make_dir(path)
		print("GlobalData::Running for the first time!")
	game_status.runs += 1
	Utility.saveDictionary(path + "game_status.json", game_status)
	


func loadSettings():
	if game_status.runs == 1:
		Utility.saveDictionary(path + "settings.json", settings)
		return
	var data = Utility.loadDictionary(path + "settings.json")
	if data:
		Utility.dictionaryCpy(settings, data)


func loadPlayerInfo():
	if game_status.runs == 1:
		Utility.saveDictionary(path + "player_info.json", player_info)
		return
	var data = Utility.loadDictionary(path + "player_info.json")
	if data:
		Utility.dictionaryCpy(player_info, data)



func savePlayerInfo():
	Utility.saveDictionary(path + "player_info.json", player_info)


func saveSettings():
	Utility.saveDictionary(path + "settings.json", settings)


func _applySettings():
	# Apply Sound settings
	Utility.setVolumeLevel(settings.sfx_vol, "weapons")
	Utility.setVolumeLevel(settings.sfx_vol, "messages")
	Utility.setVolumeLevel(settings.music_vol, "bg_sound")
	Utility.setVolumeLevel(settings.master_vol, "Master")
