extends Node

#is exporting for android or not
var is_android : bool = false
var current_game_version = 1.0
const invalid_position = Vector2(-999,-999)

#player info (pinfo) used to send info about player in multiplayer
var player_info = {
	name = "Player",
	net_id = 1,
	t_model = "t1",
	ct_model = "ct1",
	primary_gun_name = "MP5",
	sec_gun_name = "default_gun",
	XP = 0
}


var game_status = {
	game_version = 1.0
}

#game settings with default value
var game_settings = {
	control_type = "default",
	static_dpad = true,
	dpad_transparency = 128,
	particle_effects = true,
	lighting_effects = true,
	laser_targeting = true
}

#control types available
var control_types = {
	default = "res://controls/controllers/default_controller.tscn",
	simple = "res://controls/controllers/simple_controller.tscn"
}

#models available
var modelResource = {
	ct1 = preload("res://Models/ct1.tscn"),
	t1 = preload("res://Models/t1.tscn"),
}

var classResource = {
	player = preload("res://Objects/Player.tscn"),
	bot = preload("res://Objects/Bots/Bot.tscn")
}

#weapons
var weaponResource = {
	default_gun = preload("res://Objects/Weapons/Gun.tscn"),
	AK47 = preload("res://Objects/Weapons/AK47.tscn"),
	MP5 = preload("res://Objects/Weapons/MP5.tscn"),
	deagle = preload("res://Objects/Weapons/deagle.tscn")
}

#player data/stats
var player_data = {
	name = "player",
	kills = 0,
	deaths = 0,
	cash = 2000,
	XP = 0,
	guns = Array(),
	skins = Array(),
	selected_guns = Array(),
	t_model = "t1",
	ct_model = "ct1"
}

var bot_profiles = {
	bot = Array()
}

func getLevelFromXP(xp : int) -> int:
	return xp / 250

func _ready():
	var gameStatus = load_data("user://status.dat")
	if gameStatus.has("game_version"):
		if gameStatus.game_version != current_game_version:
			portGameToCurrentVersion()
		else:
			game_settings = load_data("user://settings.dat")
			player_data = load_data("user://pinfo.dat")
	else:
		saveDefaultData()
	_init_setup()



func saveDefaultData():
	save_data("user://settings.dat",game_settings)
	save_data("user://status.dat",game_status)
	
	var default_guns : Array
	default_guns.append("MP5")
	default_guns.append("default_gun")
	var default_skins : Array
	default_skins.append("t1")
	default_skins.append("ct1")
	
	var gun_data = {gun_name = "", laser = false, mag_ext = false}
	
	player_data.selected_guns = default_guns
	player_data.skins = default_skins
	player_data.t_model = default_skins[0]
	player_data.ct_model = default_skins[1]
	
	for i in default_guns:
		var data = gun_data.duplicate(true)
		data.gun_name = i
		player_data.guns.append(data)
		
	print("saving data")
	save_data("user://pinfo.dat",player_data)
	
	
func portGameToCurrentVersion():
	pass
	
#setup player info
func _init_setup():
	player_info.name = player_data.name
	player_info.t_model = player_data.t_model
	player_info.ct_model = player_data.ct_model
	player_info.XP = player_data.XP
	
	player_info.primary_gun_name = player_data.selected_guns[0]
	player_info.sec_gun_name = player_data.selected_guns[1]
	generateBotProfiles()

func saveSettings():
	save_data("user://settings.dat",game_settings)

func savePlayerData():
	save_data("user://pinfo.dat",player_data)

func save_data(save_path : String, data : Dictionary) -> void:
	var data_string = JSON.print(data)
	var file = File.new()
	var json_error = validate_json(data_string)
	if json_error:
		print_debug("JSON IS NOT VALID FOR: " + data_string)
		print_debug("error: " + json_error)
		return
	file.open(save_path, file.WRITE)
	file.store_string(data_string)
	file.close()


func load_data(save_path : String = "user://game.dat") -> Dictionary:
	var file : File = File.new()
	if not file.file_exists(save_path):
		print_debug('file [%s] does not exist; creating' % save_path)
		save_data(save_path, {})
	file.open(save_path, file.READ)
	var json : String = file.get_as_text()
	var data = parse_json(json)
	file.close()
	return data


################################################################
##################BOTS#########################################
##################BOTS#########################################
################################################################

#maximum astar calls per second
var max_Astar_calls_PS : int = 4
#current number of Astar calls
var Astar_calls : int = 0
var time : float = 0.0

func _process(delta):
	time += delta
	if time > 1.0:
		time = 0
		Astar_calls = 0

func is_Astar_ready() -> bool:
	if Astar_calls <= max_Astar_calls_PS:
		Astar_calls += 1
		return true
	return false

func generateBotProfiles():
	var bot_profile = {
		bot_name = "",
		bot_primary_gun = "MP5",
		bot_sec_gun = "default_gun",
		bot_t_skin = "t1",
		bot_ct_skin = "ct1"
	}
	
	var bot_names : Array
	bot_names.append("Raptor")
	bot_names.append("killer")
	bot_names.append("Hunter")
	bot_names.append("gladiator")
	bot_names.append("joe")
	bot_names.append("Saitama")
	bot_names.append("John")
	bot_names.append("Linus")
	bot_names.append("Diablo")
	bot_names.append("Korn")
	bot_names.append("47")
	bot_names.append("noooob")
	bot_names.append("Taask")
	
	var bot_primary_weapons : Array
	bot_primary_weapons.append("MP5")
	bot_primary_weapons.append("AK47")
	bot_primary_weapons.append("default_gun")
	
	var bot_sec_weapons : Array
	bot_sec_weapons.append("default_gun")
	bot_sec_weapons.append("deagle")
	
	var bot_t_skins : Array
	bot_t_skins.append("t1")
	
	var bot_ct_skins : Array
	bot_ct_skins.append("ct1")
	
	for b in bot_names:
		var pg_id = randi() % bot_primary_weapons.size()
		var sg_id = randi() % bot_sec_weapons.size()
		var t_sk_id = randi() % bot_t_skins.size()
		var ct_sk_id = randi() % bot_ct_skins.size()
		
		var new_bot_profile = bot_profile.duplicate(true)
		new_bot_profile.bot_name = b
		new_bot_profile.bot_primary_gun = bot_primary_weapons[pg_id]
		new_bot_profile.bot_sec_gun = bot_sec_weapons[sg_id]
		new_bot_profile.bot_t_skin = bot_t_skins[t_sk_id]
		new_bot_profile.bot_ct_skin = bot_ct_skins[ct_sk_id]
		bot_profiles.bot.append(new_bot_profile)
	
