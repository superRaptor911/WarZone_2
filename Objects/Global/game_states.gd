extends Node

#global file
#contains key resouces

#is exporting for android or not
var is_android : bool = false
const current_game_version : float = 1.34
const invalid_position = Vector2(-999,-999)
var first_run = false

#for notice
var notice_popup = preload("res://Objects/Misc/Notice.tscn")

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
	game_version = current_game_version,
	runs = 0
}

#saved
#game settings with default value
var game_settings = {
	dpad_transparency = 128,
	particle_effects = true,
	lighting_effects = true,
	music_enabled = true,
	dynamic_camera = true,
	show_fps = false,
	enable_logging = false,
	shadows = true,
	use_rich_text = true
}

#control types available
var control_types = {
	default = "res://controls/controllers/default_controller.tscn"
}

#models available
var skinResource = {
	ct1 = preload("res://Sprites/Character/ct1.bmp"),
	t1 = preload("res://Sprites/Character/t1.bmp"),
	t2 = preload("res://Sprites/Character/t2.bmp"),
	ct2 = preload("res://Sprites/Character/ct2.bmp"),
	z1 = preload("res://Sprites/Character/zombie.png"),
	z2 = preload("res://Sprites/Character/zombie2.png")
}

var skinStats = {
	ct1 = {id = "ct1", name = "S.A.S", cost = 100, team_id = 1},
	ct2 = {id = "ct2", name = "GIGN", cost = 1000, team_id = 1},
	t1 =  {id = "t1", name = "Leet", cost = 100, team_id = 0},
	t2 =  {id = "t2", name = "Terror", cost = 1000, team_id = 0},
	z1 = {id = "z1", name = "Zombie", cost = 2000, team_id = 0}
}


#classes
var classResource = {
	player = preload("res://Objects/Player.tscn"),
	bot = preload("res://Objects/Bots/Bot.tscn"),
	zombie = preload("res://Objects/Bots/Zombie.tscn")
}

#weapons
var weaponResource = {
	default_gun = preload("res://Objects/Weapons/Gun.tscn"),
	AK47 = preload("res://Objects/Weapons/AK47.tscn"),
	Aug = preload("res://Objects/Weapons/Aug.tscn"),
	MP5 = preload("res://Objects/Weapons/MP5.tscn"),
	deagle = preload("res://Objects/Weapons/deagle.tscn"),
	Awm = preload("res://Objects/Weapons/Awm.tscn"),
	Famas = preload("res://Objects/Weapons/Famas.tscn"),
	M4A1 = preload("res://Objects/Weapons/M4A1.tscn"),
	mac10 = preload("res://Objects/Weapons/mac10.tscn"),
	P90 = preload("res://Objects/Weapons/P90.tscn"),
	G3S1 = preload("res://Objects/Weapons/G3S1.tscn"),
	Galil = preload("res://Objects/Weapons/Galil.tscn"),
	M249 = preload("res://Objects/Weapons/M249.tscn")
}

#saved
#player data/stats
var player_data = {
	name = "player",
	kills = 0,
	deaths = 0,
	cash = 500,
	XP = 0,
	
	guns = [{gun_name = "MP5", laser = false, mag_ext = false}, 
			{gun_name = "default_gun", laser = false, mag_ext = false}],
	
	skins = ["t1", "ct1"],
	selected_guns = ["MP5", "default_gun"],
	t_model = "t1",
	ct_model = "ct1",
	nade_count = 2
}

#bot profiles
var bot_profiles = {
	bot = Array()
}


#last match result of user
var last_match_result = {
	kills = 0,
	deaths = 0,
	cash = 0,
	map = "",
	xp = 0
}


func getLevelFromXP(xp : int) -> int:
# warning-ignore:integer_division
	return xp / 50


func _ready():
	var gameStatus : Dictionary = load_data("user://status.dat",false)
	Logger.Log("Loading status.dat")
	
	# Check for existance and validity of savegame
	if not gameStatus.has("game_version"):
		first_run = true
		saveSettings()
		savePlayerData()
		save_data("user://status.dat",game_status,false)
	else:
		safe_cpy_dict(game_settings, load_data("user://settings.dat"))
		safe_cpy_dict(player_data, load_data("user://pinfo.dat"))
		
	_init_setup()

func safe_cpy_dict(dest_D : Dictionary, src_D : Dictionary):
	var keys = src_D.keys()
	for i in keys:
		if dest_D.has(i):
			dest_D[i] = src_D[i]

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

func save_data(save_path : String, data : Dictionary,use_enc = true) -> void:
	var data_string = JSON.print(data)
	var file = File.new()
	var json_error = validate_json(data_string)
	if json_error:
		print_debug("JSON IS NOT VALID FOR: " + data_string)
		print_debug("error: " + json_error)
		return
	
	if use_enc:
		file.open_encrypted_with_pass(save_path, File.WRITE, OS.get_unique_id())
	else:
		print("no enc")
		file.open(save_path,File.WRITE)
	file.store_string(data_string)
	file.close()


func load_data(save_path : String = "user://game.dat", use_enc = true) -> Dictionary:
	var file : File = File.new()
	if not file.file_exists(save_path):
		print_debug('file [%s] does not exist; creating' % save_path)
		save_data(save_path, {},use_enc)
	if use_enc:
		file.open_encrypted_with_pass(save_path, File.READ, OS.get_unique_id())
	else:
		print("no enc")
		file.open(save_path,File.READ)
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
		bot_ct_skin = "ct1",
		is_in_use = false
	}
	
	var bot_names = Array()
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
	bot_names.append("Carmack")
	bot_names.append("steve")
	bot_names.append("Syam")
	bot_names.append("14K")
	bot_names.append("rambo")
	bot_names.append("neerajzz")
	bot_names.append("superMan")
	bot_names.append("ihihi")
	bot_names.append("Corona")
	bot_names.append("Ebola")
		
	var bot_primary_weapons = Array()
	bot_primary_weapons.append("MP5")
	bot_primary_weapons.append("P90")
	bot_primary_weapons.append("Famas")
	bot_primary_weapons.append("mac10")
	bot_primary_weapons.append("default_gun")
	
	var bot_sec_weapons = Array()
	bot_sec_weapons.append("default_gun")
	bot_sec_weapons.append("deagle")
	
	var bot_t_skins = Array()
	bot_t_skins.append("t1")
	
	var bot_ct_skins = Array()
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
	
	Logger.Log("Generated %d bot profiles" % [bot_profiles.bot.size()])
	
