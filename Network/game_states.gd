extends Node

#is exporting for android or not
var is_android : bool = false
#game modes available
var GAME_MODE = "FFA"
var CURRENT_LEVEL = "factory"

#player info (pinfo) used to send info about player in multiplayer
var player_info = {
	name = "Player",
	net_id = 1,                 
	model_name = "default_model",
	primary_gun_name = "MP5",
	sec_gun_name = "default_gun"
}


var game_status = {
	gameV = "1.0"
}

#game settings
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
	default_model = preload("res://Models/Model.tscn"),
	zombie_model = preload("res://Models/Zombie.tscn"),
	zombie_hunter = preload("res://Models/Hunter.tscn")
}

var classResource = {
	player = preload("res://Objects/Player.tscn")
}

#weapons
var weaponResource = {
	default_gun = preload("res://Objects/Weapons/Gun.tscn"),
	AK47 = preload("res://Objects/Weapons/AK47.tscn"),
	MP5 = preload("res://Objects/Weapons/MP5.tscn"),
	Turret = preload("res://Objects/Weapons/light_turret.tscn")
}

#player data/stats
var player_data = {
	name = "player",
	kills = 0,
	deaths = 0,
	guns = "AK47 default_gun MP5",
	skins = "default_model ",
	selected_guns = "MP5 AK47 ",
	selected_model = "default_model"
}

func _ready():
	if not load_data("user://status.dat").has("gameV"):
		save_settings()
		save_data("user://status.dat",game_status)
		save_data("user://pinfo.dat",player_data)
	else:
		game_settings = load_data("user://settings.dat")
		player_data = load_data("user://pinfo.dat")
		_init_setup()

#setup player info
func _init_setup():
	player_info.name = player_data.name
	player_info.model_name = player_data.selected_model
	
	var selected_guns = player_data.selected_guns.split(" ")
	player_info.primary_gun_name = selected_guns[0]
	player_info.sec_gun_name = selected_guns[1]

func save_settings():
	save_data("user://settings.dat",game_settings)
	
func save_player_info():
	save_data("user://pinfo.dat",player_info)

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


func load_data(save_path : String = "user://game.dat"):
	var file : File = File.new()
	if not file.file_exists(save_path):
		print_debug('file [%s] does not exist; creating' % save_path)
		save_data(save_path, {})
	file.open(save_path, file.READ)
	var json : String = file.get_as_text()
	var data : Dictionary = parse_json(json)
	file.close()
	return data
################################################################



################################################################
var max_Astar_calls_PS : int = 4
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
