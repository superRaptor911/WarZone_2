extends CanvasLayer

var mode_settings = {
	round_time = 2, # Round time limit in minutes
	max_rounds = 1, #
	wait_time = 5	# Wait time(sec) before players can move
}

var time_elasped = 0
var cur_round = 1
var half_time = false
var is_wait_time = false


onready var timer_label = $top_panel/Label
onready var level = get_tree().get_nodes_in_group("Level")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Server side
	if get_tree().is_network_server():
		$Timer.start()		# Start Time keeping
		# Handle team eliminated signal
		var teams = get_tree().get_nodes_in_group("Team")
		for i in teams:
			i.connect("team_eliminated", self, "S_On_team_eliminated")
		
		level.connect("player_created", self, "on_player_joined")
		
		createBots()
		$Timer.start()
		time_elasped = 0
		is_wait_time = true
		freezeEveryone()
		$delays/round_start_dl.start(mode_settings.wait_time)
	# Peer
	else:
		pass


func on_player_joined(plr):
	if is_wait_time:
		plr.S_freezeUnit(true)
		rpc_id(int(plr.name), "on_new_round", cur_round)
	else:
		plr.killChar()


# Update current time
func _on_Timer_timeout():
	time_elasped += 1
	# Sync with peers
	if not is_wait_time:
		rpc_unreliable("P_syncTime", time_elasped)
	else:
		rpc_unreliable("P_syncWaitTime", time_elasped)
		if time_elasped > mode_settings.wait_time:
			is_wait_time = false
			time_elasped = 0


# local function to sync time elapsed
remotesync func P_syncTime(time : int):
	time_elasped = time
	# Show time remaining in panel
	var time_limit = mode_settings.round_time * 60
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


# local function to sync wait time
remotesync func P_syncWaitTime(time : int):
	# Show time remaining in panel
	var time_limit = mode_settings.wait_time
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


# Called when a team is wiped out
func S_On_team_eliminated(team):
	# Terrorist
	if team.team_id == 0:
		$audio/CTWin.play()
	# CT
	else:
		$audio/TWin.play()
	$delays/round_end_dl.start()
	$Timer.stop()


# Called when timeout
func _on_round_end_dl_timeout():
	cur_round += 1
	# round chk
	if cur_round > mode_settings.max_rounds:
		# Half time, swap sides
		if not half_time:
			cur_round = 1
			time_elasped = 0
			half_time = true
			swapTeam()
			respawnEveryone()
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			freezeEveryone()
			$delays/half_time_timer.start()
			rpc("on_half_time")
			return
		# Game ends
		else:
			endGame()
			return
			
	respawnEveryone()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$Timer.start()
	time_elasped = 0
	is_wait_time = true
	freezeEveryone()
	$delays/round_start_dl.start(mode_settings.wait_time)
	rpc("on_new_round", cur_round)


# Respawns everyone
func respawnEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_respawnUnit()


func freezeEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_freezeUnit(true)


func unfreezeEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_freezeUnit(false)

# Swap teams
func swapTeam():
	var units = get_tree().get_nodes_in_group("Unit")
	for i in units:
		level.rpc_id(1,"S_changeUnitTeam", i.name, abs(i.team.team_id - 1), false)


# Game ends
func endGame():
	pass


func _on_round_start_dl_timeout():
	unfreezeEveryone()
	rpc("on_wait_time_over")


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


remotesync func on_new_round(Round : int):
	cur_round = Round
	var round_label = $round_label
	round_label.show()
	round_label.text = "Round " + String(cur_round)
	UiAnim.animZoomIn([round_label])


remotesync func on_wait_time_over():
	$round_label.hide()
	$audio/LetsGo.play()


remotesync func on_half_time():
	var half_time_label = $first_half_label
	half_time_label.show()
	UiAnim.animZoomIn([half_time_label])
	var plr = level.get_node(String(game_states.player_info.net_id))
	if plr:
		plr.canvas_modulate.color = Color.gray
	else:
		print("Local player not found ", game_states.player_info.net_id)


remotesync func on_half_time_ends():
	$first_half_label.hide()
	var plr = game_server._unit_data_list.get(String(game_states.player_info.net_id))
	if plr:
		$Tween.interpolate_property(plr.ref.canvas_modulate, "color", Color.gray,
			Color.white, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
		$Tween.start()



func _on_half_time_timer_timeout():
	$Timer.start()
	time_elasped = 0
	is_wait_time = true
	$delays/round_start_dl.start(mode_settings.wait_time)
	rpc("on_half_time_ends")
	rpc("on_new_round", cur_round)
