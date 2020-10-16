extends "res://Objects/Game_modes/FFA/FFAMinimap.gd"

var timer = Timer.new()
var zombies = []

func _ready():
	timer.wait_time = 1.5
	add_child(timer)
	timer.connect("timeout", self, "On_timer_timeout")
	timer.start()


func On_timer_timeout():
	zombies = get_tree().get_nodes_in_group("Monster")



func showPlayersInMap():
	if local_player:
		for u in game_server._unit_data_list:
			var i = game_server._unit_data_list[u].ref
			if i.alive:
				var rel_pos = (i.position - ref_pos) * Scale
				rel_pos.x = clamp(rel_pos.x, 0, rect_size.x)
				rel_pos.y = clamp(rel_pos.y, 0, rect_size.y)
				if i == local_player:
					draw_data.append({p = rel_pos, c = Color8(255,255,255,255)})
				elif i.team.team_id == local_player.team.team_id:
					draw_data.append({p = rel_pos, c = Color8(50,255,50,255)})
				elif i.last_fired_timestamp + 5 > OS.get_ticks_msec() / 1000 or i.spotted_by_enimies:
					draw_data.append({p = rel_pos, c = Color8(255,0,0,255)})
		
		for i in zombies:
			if is_instance_valid(i):
				var rel_pos = (i.position - ref_pos) * Scale
				rel_pos.x = clamp(rel_pos.x, 0, rect_size.x)
				rel_pos.y = clamp(rel_pos.y, 0, rect_size.y)
				draw_data.append({p = rel_pos, c = Color8(255,0,0,255)})
		minimap_icons.update()
