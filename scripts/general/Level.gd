extends Node2D


func _ready():
	_loadScripts()

func _loadScripts():
	var spawn_manager = load("res://scripts/general/spawnManager.gd").new()
	add_child(spawn_manager)
	var sync_script = load("res://scripts/general/SyncScript.gd").new()
	add_child(sync_script)
	if !get_tree().is_network_server():
		sync_script.syncAll(spawn_manager)
