extends "res://Objects/Misc/Minimap.gd"

#run Minimap at lower refresh rate
export var update_at_frame : int = 4

var current_frame : int  = 0

func _process(delta):
	current_frame += 1
	if current_frame == update_at_frame:
		moveMapWithPlayer()
		showPlayersInMap()
		current_frame = 0
