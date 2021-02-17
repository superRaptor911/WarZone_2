extends Node2D


func _ready():
	var spawn_manager = load("res://scripts/general/spawnManager.gd").new()
	add_child(spawn_manager)
