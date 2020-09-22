extends CanvasLayer

var mode_settings = {
	round_time = 2, # Round time limit in minutes
	max_rounds = 5, # Maximum rounds in 1 half
}


var time_elasped = 0		# Elasped time
var cur_round = 1			# Current round
var half_time = false		# Counter for tracking half time
var is_wait_time = false	# Counter for wait time
var wait_duration = 5.0		# Wait time duration


onready var timer_label = $top_panel/Label
onready var level = get_tree().get_nodes_in_group("Level")[0]
onready var teams = get_tree().get_nodes_in_group("Team")


var end_screen = preload("res://Objects/Game_modes/Elimination/EndScreen.tscn").instance()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Server side
	if get_tree().is_network_server():
		$Timer.start()		# Start Time keeping
		# Handle team eliminated signal
		for i in teams:
			i.connect("team_eliminated", self, "S_On_team_eliminated")
		
		level.connect("player_created", self, "on_player_joined")
		
		createBots()
		$Timer.start()
		time_elasped = 0
		is_wait_time = true
		freezeEveryone()
		$delays/round_start_dl.start(wait_duration)
	# Peer
	else:
		pass

# Handle player connection
func on_player_joined(plr):
	if is_wait_time:
		plr.S_freezeUnit(true)
		rpc_id(int(plr.name), "P_on_new_round", cur_round)
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
		if time_elasped > wait_duration:
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
	var time_limit = wait_duration
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


# Called when a team is wiped out
func S_On_team_eliminated(team):	
	# Get winning team and add score
	var winner = teams[0]
	if winner.team_id == team.team_id:
		winner = teams[1]
	winner.addScore(2)
	
	# Update scores
	var t_score
	var ct_score
	if teams[0].team_id == 0:
		t_score = teams[0].score
		ct_score = teams[1].score
	else:
		t_score = teams[1].score
		ct_score = teams[0].score
	rpc("P_updateScores", t_score, ct_score, winner.team_id)
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
			rpc("P_on_half_time_starts")
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
	$delays/round_start_dl.start(wait_duration)
	rpc("P_on_new_round", cur_round)


# Respawns everyone
func respawnEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_respawnUnit()


# Freeze everyone, prevents from moving
func freezeEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_freezeUnit(true)


# Un-Freeze everyone
func unfreezeEveryone():
	var players = get_tree().get_nodes_in_group("Unit")
	for i in players:
		i.S_freezeUnit(false)


# Swap teams
func swapTeam():
	var units = get_tree().get_nodes_in_group("Unit")
	for i in units:
		level.rpc_id(1,"S_changeUnitTeam", i.name, abs(i.team.team_id - 1), false)
	# Swap scores
	var temp = teams[0].score
	teams[0].score = teams[1].score
	teams[1].score = temp



# Game ends, called when game ends
func endGame():
	$delays/game_end_timer.start()


# Called when wait time is over, Server side
func _on_round_start_dl_timeout():
	unfreezeEveryone()
	rpc("P_on_wait_time_over")


# Function to create bots
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


# Called every round on peers
remotesync func P_on_new_round(Round : int):
	cur_round = Round
	# Show message
	var round_label = $main_label
	round_label.show()
	if Round == mode_settings.max_rounds:
		if not half_time:
			round_label.text = "Last Round of this half"
		else:
			round_label.text = "Last Round"
	else:
		round_label.text = "Round " + String(cur_round)
	UiAnim.animZoomIn([round_label])


# Called when wait time is over
remotesync func P_on_wait_time_over():
	$main_label.hide()
	$audio/LetsGo.play()


# Called when half time starts
remotesync func P_on_half_time_starts():
	half_time = true
	# Show message
	var half_time_label = $main_label
	half_time_label.show()
	half_time_label.text = "End of First Half"
	UiAnim.animZoomIn([half_time_label])
	# apply gray tint
	var plr = game_server._unit_data_list.get(String(game_states.player_info.net_id))
	if plr:
		plr.ref.canvas_modulate.color = Color.gray
	else:
		print("Local player not found ", game_states.player_info.net_id)


# Called when half time ends
remotesync func P_on_half_time_ends():
	$main_label.hide()
	# Remove gray tint gradually
	var plr = game_server._unit_data_list.get(String(game_states.player_info.net_id))
	if plr:
		$Tween.interpolate_property(plr.ref.canvas_modulate, "color", Color.gray,
			Color.white, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
		$Tween.start()


# Called when half time ends, Server side
func _on_half_time_timer_timeout():
	$Timer.start()
	time_elasped = 0
	is_wait_time = true
	$delays/round_start_dl.start(wait_duration)
	rpc("P_on_half_time_ends")
	rpc("P_on_new_round", cur_round)


# Update and show scores in the panel
remotesync func P_updateScores(t_score, ct_score, winner_id):
	$top_panel/t/Label.text = String(t_score)
	$top_panel/ct/Label.text = String(ct_score)
	# Play audio
	# Terrorist
	if winner_id == 0:
		$audio/TWin.play()
		var label = $main_label
		label.text = "Terrorists win"
		label.show()
		UiAnim.animZoomIn([label])
	# CT
	else:
		$audio/CTWin.play()
		var label = $main_label
		label.text = "CT win"
		label.show()
		UiAnim.animZoomIn([label])



func _on_game_end_timer_timeout():
	rpc("P_on_game_ends")



remotesync func P_on_game_ends():
	add_child(end_screen)
	end_screen.showScreen()
	$top_panel.hide()
