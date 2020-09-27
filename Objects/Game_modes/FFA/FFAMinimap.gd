extends "res://Objects/Misc/Minimap.gd"

#run Minimap at lower refresh rate
export var update_at_frame : int = 4

var current_frame : int  = 0

func _process(_delta):
	current_frame += 1
	if current_frame == update_at_frame:
		moveMapWithPlayer()
		showPlayersInMap()
		current_frame = 0

func showPlayersInMap():
	if local_player:
		#hide all the dots
		for i in dotsList:
			i.hide()
		
		var sp_index = 0
		for u in game_server._unit_data_list:
			var i = game_server._unit_data_list[u].ref
			if i.alive:
				var rel_pos = (i.position - ref_pos) * Scale
				rel_pos.x = clamp(rel_pos.x, 0, rect_size.x)
				rel_pos.y = clamp(rel_pos.y, 0, rect_size.y)
				if i == local_player:
					dotsList[sp_index].modulate = Color8(255,255,255,255)
					dotsList[sp_index].show()
					dotsList[sp_index].position = rel_pos
				elif i.team.team_id == local_player.team.team_id:
					dotsList[sp_index].modulate = Color8(50,255,50,255)
					dotsList[sp_index].show()
					dotsList[sp_index].position = rel_pos
				elif i.last_fired_timestamp + 5 > OS.get_ticks_msec() / 1000 or i.spotted_by_enimies:
					dotsList[sp_index].modulate = Color8(255,0,0,255)
					dotsList[sp_index].show()
					dotsList[sp_index].position = rel_pos
				sp_index += 1
				if sp_index >= 14:
					break
