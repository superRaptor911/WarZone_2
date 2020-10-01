extends "res://Objects/Misc/Minimap.gd"


#run Minimap at lower refresh rate
export var update_at_frame : int = 4

onready var minimap_icons = $Minimap_icons
onready var chk_points = get_tree().get_nodes_in_group("CheckPoint")

var current_frame : int  = 0
var draw_data = Array()


func _process(_delta):
	current_frame += 1
	if current_frame == update_at_frame:
		moveMapWithPlayer()
		showPlayersInMap()
		showCapturePoints()
		current_frame = 0
		minimap_icons.update()


func showPlayersInMap():
	if local_player:
		for u in game_server._unit_data_list:
			var i = game_server._unit_data_list[u].ref
			if i.alive:
				var rel_pos = (i.position - ref_pos) * Scale
				rel_pos.x = clamp(rel_pos.x, 0, rect_size.x)
				rel_pos.y = clamp(rel_pos.y, 0, rect_size.y)
				if i == local_player:
					draw_data.append({p = rel_pos, sz = 2, c = Color8(255,255,255,255)})
				elif i.team.team_id == local_player.team.team_id:
					draw_data.append({p = rel_pos, sz = 2, c = Color8(50,255,50,255)})
				elif i.last_fired_timestamp + 5 > OS.get_ticks_msec() / 1000 or i.spotted_by_enimies:
					draw_data.append({p = rel_pos, sz = 2, c = Color8(255,0,0,255)})



func showCapturePoints():
	for i in chk_points:
		var rel_pos = (i.position - ref_pos) * Scale
		rel_pos.x = clamp(rel_pos.x, 0, rect_size.x)
		rel_pos.y = clamp(rel_pos.y, 0, rect_size.y)
		var clr = Color.white
		if i.i.holding_team != -1:
			clr = Color8(255 * (1 - i.holding_team) , 0, 255 * i.holding_team)
		draw_data.append({p = rel_pos, sz = 8, c = clr})
