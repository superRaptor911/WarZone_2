extends Node2D

signal scripts_loaded

func _ready():
	_loadScripts()


func _loadScripts():
	# Load spawn_manager
	var spawn_manager = load("res://scripts/general/spawnManager.gd").new()
	add_child(spawn_manager)
	# Load sync script
	var sync_script = load("res://scripts/general/SyncScript.gd").new()
	add_child(sync_script)
	# Load recources
	var resources = load("res://scripts/general/Resources.gd").new()
	get_tree().root.add_child(resources)
	emit_signal("scripts_loaded")
	# Sync with server
	if !get_tree().is_network_server():
		sync_script.syncAll(spawn_manager)
