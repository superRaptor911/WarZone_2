extends Node

# Entities
var entities = {
	unit = preload("res://objects/characters/player/Player.tscn")
	}

# Guns here
var guns = {
	glock18 = preload("res://objects/guns/Glock18.tscn"),
	ak47 = preload("res://objects/guns/Ak47.tscn"),
	aug = preload("res://objects/guns/Aug.tscn"),
	awp = preload("res://objects/guns/Awp.tscn"),
	}


# Skins
var skins = []

# Hud
var hud = preload("res://ui/hud/Hud.tscn")

var scoreboard = null

# Stats
var gun_stats    = {}	# Dictionary for keeping gun stats 


func _ready():
	name = "Resources"
	_loadStats()


# Load stats from json file into above dictionary
func _loadStats():
	gun_stats      = Utility.loadDictionary("res://objects/guns/gun_stats.json")
