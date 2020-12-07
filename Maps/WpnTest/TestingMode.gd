extends Node

onready var level = get_tree().get_nodes_in_group("Level")[0]

func _ready():
	level.connect("player_created", self, "on_player_joined")
	

func on_player_joined(plr):
	plr.cash = 99999
	plr.hud.add_child(preload("res://Objects/Misc/wpnTweaker.tscn").instance())
	plr.HP = 9999
