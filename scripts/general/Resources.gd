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
	deagle = preload("res://objects/guns/Deagle.tscn"),
	famas = preload("res://objects/guns/Famas.tscn"),
	g3 = preload("res://objects/guns/G3.tscn"),
	galil = preload("res://objects/guns/Galil.tscn"),
	m4a1 = preload("res://objects/guns/M4A1.tscn"),
	m249 = preload("res://objects/guns/M249.tscn"),
	mac10 = preload("res://objects/guns/Mac10.tscn"),
	mp5 = preload("res://objects/guns/Mp5.tscn"),
	p90 = preload("res://objects/guns/P90.tscn"),
	scout = preload("res://objects/guns/Scout.tscn"),
	tmp = preload("res://objects/guns/Tmp.tscn"),
	ump45 = preload("res://objects/guns/Ump45.tscn"),
	usp = preload("res://objects/guns/Usp.tscn"),
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
