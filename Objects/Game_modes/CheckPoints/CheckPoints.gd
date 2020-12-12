extends CanvasLayer


var mode_settings = {
	round_time = 8, # Round time limit in minutes
	max_score = 500,
	respawn_time = 8
}

var CP_minimap = preload("res://Objects/Game_modes/CheckPoints/CPMinimap.tscn")
var end_screen = preload("res://Objects/Game_modes/Elimination/EndScreen.tscn").instance()
var scoreboard = preload("res://Objects/Ui/elimScoreboard.tscn")

var time_elasped = 0
var focused_point = null
var teams = Array()


onready var timer_label = $top_panel/Label
onready var points_node = $top_panel/points
onready var progress_bar = $top_panel/ProgressBar
onready var t_score_label = $top_panel/t/Label
onready var ct_score_label = $top_panel/ct/Label
onready var label_node = $Label
onready var label_hide_timer = $Delays/hide_Label_dl
onready var level = get_tree().get_nodes_in_group("Level")[0]
onready var checkpoints = get_tree().get_nodes_in_group("CheckPoint")


func _ready():
	# Get teams and index them acording to team_id
	var _teams = get_tree().get_nodes_in_group("Team")
	if _teams[0].team_id == 0:
		teams = _teams
	else:
		teams.append(_teams[1])
		teams.append(_teams[0])
	
	
	for i in $top_panel/points.get_children():
		i.hide()
	
	for i in checkpoints:
		i.connect("team_captured_point", self, "P_on_team_captured_point")
		i.connect("local_player_entered", self, "P_on_local_player_entered")
		i.connect("local_player_exited", self, "P_on_local_player_exited")
		P_on_team_captured_point(i, false)
	
	level.connect("player_created", self, "P_on_player_joined")
	
	if get_tree().is_network_server():
		level.connect("player_created", self, "S_on_unit_joined")
		level.connect("bot_created", self, "S_on_unit_joined")
		$Delays/updateScore_dl.start()
		createBots()
		$Timer.start()
		


func _on_Timer_timeout():
	time_elasped += 1
	rpc_unreliable("P_syncTime", time_elasped)
	
	if time_elasped > mode_settings.round_time * 60:
		$Timer.stop()
		$Delays/updateScore_dl.stop()
		$Delays/game_end_dl.start()
		rpc("P_showWinners")


remotesync func P_syncTime(time : int):
	time_elasped = time
	# Show time remaining in panel
	var time_limit = mode_settings.round_time * 60
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


func P_on_team_captured_point(point, show_msg = true):
	var rect = points_node.get_node(String(point.id))
	rect.show()
	var team_name = "Terrorists"
	if point.holding_team == 0:
		rect.color = Color8(201, 55, 31)
	elif point.holding_team == 1:
		team_name = "CT"
		rect.color = Color8(17,64, 194)
	else:
		rect.color = Color.white
	
	if show_msg:
		label_node.show()
		label_node.text = "%s captured Point %d" % [team_name, point.id]
		label_hide_timer.start()
		


func P_on_local_player_entered(point):
	focused_point = point
	progress_bar.value = point.value
	progress_bar.max_value = point.max_points
	progress_bar.show()


func P_on_local_player_exited():
	focused_point = null
	progress_bar.hide()


func _process(_delta):
	if focused_point:
		progress_bar.value = focused_point.value


func P_on_player_joined(plr):
	if plr.is_network_master():
		var minimap_panel = plr.hud.get_node("Minimap")
		var minimap = minimap_panel.get_node("Minimap")
		var new_minimap = CP_minimap.instance()
		new_minimap.name = "Minimap"
		new_minimap.rect_size = minimap.rect_size
		minimap.queue_free()
		minimap_panel.add_child(new_minimap)
		print("Loaded Custom minimap")



func S_on_unit_joined(unit):
	if unit.is_in_group("Bot"):
		unit.connect("bot_killed",self,"S_on_unit_killed")
	else:
		unit.connect("player_killed",self,"S_on_unit_killed")


func S_on_unit_killed(unit):
	unit.get_node("respawn_timer").start()


func createBots():
	Logger.Log("Creating bots")
	var bots = Array()
	var bot_count = game_server.bot_settings.bot_count
	print("Bot count = ",game_server.bot_settings.bot_count)
	game_server.bot_settings.index = 0
	var ct = false
	
	if bot_count > game_states.bot_profiles.bot.size():
		Logger.Log("Not enough bot profiles. Required %d , Got %d" % [bot_count, game_states.bot_profiles.bot.size()])
	
	for i in game_states.bot_profiles.bot:
		i.is_in_use = false
		if game_server.bot_settings.index < bot_count:
			i.is_in_use = true
			var data = level.unit_data_dict.duplicate(true)
			data.pn = i.bot_name
			data.g1 = i.bot_primary_gun
			data.g2 = i.bot_sec_gun
			data.b = true
			data.k = 0
			data.d = 0
			data.scr = 0
			data.pg = i.bot_primary_gun
			data.sg = i.bot_sec_gun
			
			#assign team
			if ct:
				data.tId = 1
				data.s = i.bot_ct_skin
				ct = false
			else:
				data.tId = 0
				data.s = i.bot_t_skin
				ct = true
			
			data.p = level.getSpawnPosition(data.tId)
			#giving unique node name
			data.n = "bot" + String(69 + game_server.bot_settings.index)
			bots.append(data)
			game_server.bot_settings.index += 1
	
	#spawn bot
	for i in bots:
		level.createUnit(i)
		Logger.Log("Created bot [%s] with ID %s" % [i.pn, i.n])



func _on_updateScore_dl_timeout():
	for i in checkpoints:
		if teams[0].team_id == i.holding_team:
			teams[0].score += 1
		elif teams[1].team_id == i.holding_team:
			teams[1].score += 1
	
	rpc("P_update_displayScore", teams[0].score, teams[1].score)



remotesync func P_update_displayScore(t_scr, ct_scr):
	teams[0].score = t_scr
	teams[1].score = ct_scr
	
	t_score_label.text = String(t_scr)
	ct_score_label.text = String(ct_scr)


remotesync func P_showWinners():
	label_node.show()
	if teams[0].score > teams[1].score:
		$Sfx/t_win.play()
		label_node.text = "Terrorists win"
	elif teams[0].score < teams[1].score:
		$Sfx/ct_win.play()
		label_node.text = "CT win"
	else:
		label_node.text = "Tie"
	
	yield(get_tree().create_timer(2), "timeout")
	label_node.hide()


func _on_game_end_dl_timeout():
	rpc("P_endGame")
	$Delays/game_restart_dl.start()



remotesync func P_endGame():
	add_child(end_screen)
	end_screen.showScreen()
	$top_panel.hide()
	label_node.hide()


func _on_game_restart_dl_timeout():
	rpc("P_game_restart")
	respawnEveryone()
	$Timer.start()
	$Delays/updateScore_dl.start()
	for i in teams:
		i.score = 0



remotesync func P_game_restart():
	remove_child(end_screen)
	$top_panel.show()
	$top_panel/t/Label.text = String(0)
	$top_panel/ct/Label.text = String(0)
	time_elasped = 0


func respawnEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_respawnUnit()


func _on_hide_Label_dl_timeout():
	label_node.hide()
