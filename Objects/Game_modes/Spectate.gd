extends Node

var current_spec_player = null
var spec_id = 0


signal leave_spec_mode

func _enter_tree():
#	MenuManager.admob.show_banner()
	pass


func _ready():
	print("spectating")
	specRandomPlayer()
	
	var level_group = get_tree().get_nodes_in_group("Level")
	if not level_group.empty():
		var level = level_group[0]
		var world_Size = level.get_node("BaseMap/height").get_used_rect().size
		$Minimap.rect_size = world_Size * 8



func specNextPlayer():
	var alive_players = Array()
	for i in game_server._unit_data_list:
		var p = game_server._unit_data_list[i].ref
		if p.alive:
			alive_players.append(p)
		
	if not alive_players.empty():
		spec_id += 1
		if spec_id >= alive_players.size():
			spec_id = 0
		 
		selectPlayer(alive_players[spec_id])
	else:
		selectPlayer(null)


func specRandomPlayer():
	var alive_players = Array()
	for i in game_server._unit_data_list:
		var p = game_server._unit_data_list[i].ref
		if p.alive:
			alive_players.append(p)
		
	if not alive_players.empty():
		spec_id = randi() % alive_players.size()
		selectPlayer(alive_players[spec_id])
	else:
		selectPlayer(null)


func selectPlayer(plr):
	if current_spec_player:
		current_spec_player.get_node("Camera2D").current = false
		$Minimap.local_player = null
		current_spec_player.disconnect("char_killed", self, "specNextPlayer")
		current_spec_player = null
	
	if plr:
		current_spec_player = plr
		current_spec_player.get_node("Camera2D").current = true
		$Minimap.local_player = current_spec_player
		current_spec_player.connect("char_killed", self, "specNextPlayer")


func _on_spec_pressed():
	specNextPlayer()


func _on_menu_pressed():
	if current_spec_player:
		current_spec_player.get_node("Camera2D").current = false
	emit_signal("leave_spec_mode")


func _exit_tree():
	selectPlayer(null)
	MenuManager.admob.hide_banner()
