extends Node

# Entities
var entities = {
	unit = preload("res://objects/characters/player/Player.tscn")
	}

# bullet scenes
# var bullets = {
# 	_9mm_fmj = preload("res://objects/bullets/9mm_fmj.tscn"),
# 	_9mm_ap = preload("res://objects/bullets/9mm_fmj.tscn"),
	# }

# Guns here
var guns = {
	glock18 = preload("res://objects/guns/Glock18.tscn"),
	ak47 = preload("res://objects/guns/Ak47.tscn"),
	}

# Gun sfx
var gun_sounds = {
	glock18 = [preload("res://resources/sound/sfx/weapons/glock18-1.wav"),preload("res://resources/sound/sfx/weapons/glock18-2.wav")],
	ak47 = [preload("res://resources/sound/sfx/weapons/ak47-1.wav"), preload("res://resources/sound/sfx/weapons/ak47-2.wav")]
	}

# Skins
var skins = []

# Hud
var hud = preload("res://ui/hud/Hud.tscn")

var scoreboard = null

# Stats
var bullet_stats = {}	# Dictionary for keeping bullet stats
var gun_stats    = {}	# Dictionary for keeping gun stats 


func _ready():
	name = "Resources"
	_loadStats()


# Load stats from json file into above dictionary
func _loadStats():
	bullet_stats   = Utility.loadDictionary("res://objects/bullets/bullet_stats.json")
	gun_stats      = Utility.loadDictionary("res://objects/guns/gun_stats.json")
