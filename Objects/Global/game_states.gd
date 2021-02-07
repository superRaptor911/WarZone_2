extends Node

#global file
#contains key resouces

#is exporting for android or not
var is_android		= true
var is_server		= false
var is_sysAdmin		= false

const current_game_version : float = 1.52
const invalid_position = Vector2(-999,-999)
var first_run = false

#for notice
var notice_popup = preload("res://Objects/Misc/Notice.tscn")

# Player info (pinfo) used to send info about player in multiplayer
# Temporary data
var player_info = {
	name 				= "Player",			# Player Name
	net_id 				= 1,				# Player ID
	t_model 			= "t1",				# T skin
	ct_model 			= "ct1",			# ct Skin
	primary_gun_name 	= "",				# primary gun
	sec_gun_name 		= "Glock",	# secondary gun
	XP 					= 0,				# player xp
	ping 				= -1,				# Player ping
}

# Game Status
var game_status = {
	game_version 	= current_game_version,
	runs			= 0,
	is_lang_set 	= false
}

#saved
#game settings with default value
var game_settings = {
	dpad_transparency	= 128,			# Dpad transparency
	particle_effects	= true,			# Particle effects
	lighting_effects 	= true,			# Lighting effects
	show_fps 			= true,			# Show Fps counter
	shadows 			= true,			# Shadows
	use_rich_text 		= true,			# Use rich text
	body_stay_time 		= 10,			# Body stay time
	lang 				= 'en',			# Game Language
	dynamic_camera 		= true,			# Dynamic cam
	music_enabled 		= true,			# Enable music
	enable_logging 		= (false || is_server),	# Enable event logging
}

#control types available
var control_types = {
	default = "res://controls/controllers/default_controller.tscn"
}

# Skins available
var skinResource = {
	ct1		= preload("res://Sprites/Character/ct1.bmp"),
	t1		= preload("res://Sprites/Character/t1.bmp"),
	t2		= preload("res://Sprites/Character/t2.bmp"),
	ct2		= preload("res://Sprites/Character/ct2.bmp"),
	z1		= preload("res://Sprites/Character/zombie.png"),
	z2		= preload("res://Sprites/Character/zombie2.png")
}

var skinStats = {
	ct1 = {id = "ct1", name = "S.A.S", cost = 100, team_id = 1},
	ct2 = {id = "ct2", name = "GIGN", cost = 1000, team_id = 1},
	t1 =  {id = "t1", name = "Leet", cost = 100, team_id = 0},
	t2 =  {id = "t2", name = "Terror", cost = 1000, team_id = 0},
	z1 = {id = "z1", name = "Zombie", cost = 2000, team_id = 0}
}


# Basic classes
var classResource = {
	player = preload("res://Objects/Player.tscn"),
	bot = preload("res://Objects/Bots/Bot.tscn"),
	zombie = preload("res://Objects/Bots/Zombie.tscn")
}

# Weapons
var weaponResource = {
	Glock 			= preload("res://Objects/Weapons/Gun.tscn"),
	AK47 			= preload("res://Objects/Weapons/AK47.tscn"),
	Aug				= preload("res://Objects/Weapons/Aug.tscn"),
	MP5				= preload("res://Objects/Weapons/MP5.tscn"),
	deagle			= preload("res://Objects/Weapons/deagle.tscn"),
	Awm				= preload("res://Objects/Weapons/Awm.tscn"),
	Famas			= preload("res://Objects/Weapons/Famas.tscn"),
	M4A1			= preload("res://Objects/Weapons/M4A1.tscn"),
	mac10			= preload("res://Objects/Weapons/mac10.tscn"),
	P90				= preload("res://Objects/Weapons/P90.tscn"),
	G3S1			= preload("res://Objects/Weapons/G3S1.tscn"),
	Galil 			= preload("res://Objects/Weapons/Galil.tscn"),
	M249 			= preload("res://Objects/Weapons/M249.tscn"),
	Tmp				= preload("res://Objects/Weapons/Tmp.tscn"),
	Usp				= preload("res://Objects/Weapons/Usp.tscn"),
	Ump45			= preload("res://Objects/Weapons/Ump45.tscn")
}

var weaponStats = {
	Glock 			= { cost = 400, dmg = 13, rof = 3, rec = 0.10, sprd = 1 },
	Usp				= { cost = 600, dmg = 20, rof = 4, rec = 0.20, sprd = 3 },
	deagle			= { cost = 800, dmg = 60, rof = 2, rec = 0.20, sprd = 3 },
	mac10			= { cost = 1050, dmg = 13, rof = 12, rec = 0.30, sprd = 4 },
	Tmp				= { cost = 1300, dmg = 15, rof = 12, rec = 0.20, sprd = 4 },
	MP5				= { cost = 2000, dmg = 20, rof = 10, rec = 0.20, sprd = 3 },
	Ump45			= { cost = 2300, dmg = 20, rof = 10, rec = 0.20, sprd = 3 },
	Galil 			= { cost = 2500, dmg = 20, rof = 9, rec = 0.50, sprd = 3 },
	P90				= { cost = 2800, dmg = 15, rof = 14, rec = 0.10, sprd = 4 },
	Famas			= { cost = 3300, dmg = 22, rof = 8, rec = 0.20, sprd = 3 },
	AK47 			= { cost = 3500, dmg = 35, rof = 7, rec = 1.30, sprd = 1 },
	M4A1			= { cost = 3900, dmg = 27, rof = 9, rec = 0.30, sprd = 3 },
	Aug				= { cost = 4200, dmg = 27, rof = 9, rec = 0.70, sprd = 1 },
	G3S1			= { cost = 4600, dmg = 60, rof = 3, rec = 1.00, sprd = 2 },
	Awm				= { cost = 5500, dmg = 400, rof = 1, rec = 0.20, sprd = 1 },
	M249 			= { cost = 6000, dmg = 26, rof = 12, rec = 0.30, sprd = 2 },
}


# Saved data
# Player data/stats
var player_data = {
	name		= "player",
	desc		= "",
	kills		= 0,
	deaths		= 0,
	XP			= 0,
	skins		= ["t1", "ct1"],
	t_model		= "t1",
	ct_model	= "ct1",
	nade_count	= 2
}

#bot profiles
var bot_profiles = {
	bot = Array()
}


# Last match result of user
var match_result = {
	kills		= 0,
	deaths		= 0,
	map			= "",
	mode		= "",
	cash		= 0,	
	xp			= 0,
	msg			= ""
}


func getLevelFromXP(xp : int) -> int:
# warning-ignore:integer_division
	return xp / 50


func _ready():
	if not is_server:
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
			safe_cpy_dict(game_status, gameStatus)
	_init_setup()

# Cpy contents of dictionary
func safe_cpy_dict(dest_D : Dictionary, src_D : Dictionary):
	if not src_D:
		return
	var keys = src_D.keys()
	for i in keys:
		if dest_D.has(i):
			dest_D[i] = src_D[i]


func stringToType(string : String):
	var type = 'i'
	for i in string:
		if i == '.':
			type = 'f'
			break
		if not (i  >= '0' and i <= '9'):
			type = 's'
			break
		
	if type == 'f':
		print("float")
		return float(string)
	if type == 'i':
		print("int")
		return int(string)
	return string


# setup player info
func _init_setup():
	print("Initing")
	player_info.name = player_data.name
	player_info.t_model = player_data.t_model
	player_info.ct_model = player_data.ct_model
	player_info.XP = player_data.XP
	generateBotProfiles()


func saveSettings():
	save_data("user://settings.dat",game_settings)


func savePlayerData():
	save_data("user://pinfo.dat",player_data)

# Save Data to file
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


# Load Data from file
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
		bot_name 		= "",
		bot_primary_gun = "",
		bot_sec_gun 	= "Glock",
		bot_t_skin 		= "t1",
		bot_ct_skin 	= "ct1",
		is_in_use 		= false
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
		
	var bot_t_skins = Array()
	bot_t_skins.append("t1")
	var bot_ct_skins = Array()
	bot_ct_skins.append("ct1")
	

	# Generate, Randomize
	for b in bot_names:
		var t_sk_id 	= randi() % bot_t_skins.size()
		var ct_sk_id 	= randi() % bot_ct_skins.size()
		
		var new_bot_profile = bot_profile.duplicate(true)
		new_bot_profile.bot_name = b
		new_bot_profile.bot_primary_gun = ""
		new_bot_profile.bot_sec_gun = "Glock"
		new_bot_profile.bot_t_skin = bot_t_skins[t_sk_id]
		new_bot_profile.bot_ct_skin = bot_ct_skins[ct_sk_id]	
		bot_profiles.bot.append(new_bot_profile)
	
	Logger.Log("Generated %d bot profiles" % [bot_profiles.bot.size()])
