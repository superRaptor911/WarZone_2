extends Node

# bullet scenes
var bullets = {
	_9mm_fmj = preload("res://objects/bullets/9mm_fmj.tscn"),
	_9mm_ap = preload("res://objects/bullets/9mm_fmj.tscn"),
	}

var guns = {
	glock18 = preload("res://objects/guns/Glock18.tscn")
	}


var bullet_stats = {}	# Dictionary for keeping bullet stats
var gun_stats    = {}	# Dictionary for keeping gun stats 

func _ready():
	name = "Resources"
	_loadStats()


# Load stats from json file into above dictionary
func _loadStats():
	bullet_stats   = Utility.loadDictionary("res://objects/bullets/bullet_stats.json")
	gun_stats      = Utility.loadDictionary("res://objects/guns/gun_stats.json")
