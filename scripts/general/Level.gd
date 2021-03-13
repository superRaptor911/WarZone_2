extends Node2D

func _ready():
	_loadScripts()


func _loadScripts():
	# Load spawn_manager
	var spawn_manager = load("res://scripts/general/spawnManager.gd").new()
	add_child(spawn_manager)
	Signals.emit_signal("spawnmanger_loaded")
	# Load sync script
	var sync_script = load("res://scripts/general/SyncScript.gd").new()
	add_child(sync_script)
	Signals.emit_signal("syncscript_loaded")
	# Load recources
	var resources = load("res://scripts/general/Resources.gd").new()
	get_tree().root.add_child(resources)
	Signals.emit_signal("resources_loaded")
	# Sync with server
	if !get_tree().is_network_server():
		sync_script.syncAll(spawn_manager)
