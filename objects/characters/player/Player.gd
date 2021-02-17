extends "res://objects/characters/entity/Entity.gd"

onready var camera : Camera2D = get_node("camera")

func _ready():
	if is_network_master():
		camera.current = true

