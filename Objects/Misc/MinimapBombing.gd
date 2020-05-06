extends "res://Objects/Misc/Minimap.gd"

func showPlayersInMap():
	if local_player:
		#hide all the dots
		for i in dotsList:
			i.hide()
		var sp_index = 0
		for i in playerList:
			if i.alive:
				var rel_pos = (i.position - ref_pos) * Scale
				if rel_pos.x > 0 && rel_pos.y > 0 && rel_pos.x < rect_size.x && rel_pos.y < rect_size.y:
					if i == local_player:
						dotsList[sp_index].modulate = Color8(255,255,255,255)
					elif i.team.team_id == local_player.team.team_id:
						dotsList[sp_index].modulate = Color8(50,255,50,255)
					else:
						dotsList[sp_index].modulate = Color8(255,50,50,255)
					if i.team.team_id == 0  and i.is_in_group("bomber"):
						dotsList[sp_index].modulate = Color8(255,165,0,255)
					dotsList[sp_index].show()
					dotsList[sp_index].position = rel_pos
					sp_index += 1
					if sp_index >= 12:
						break

