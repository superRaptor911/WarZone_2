extends CanvasLayer

var mode_settings = {
	round_time = 2, # Round time limit in minutes
	max_rounds = 5, #
	wait_time = 5	# Wait time(sec) before players can move
}

var time_elasped = 0
var cur_round = 0
var half_time = false
var is_wait_time = false


onready var timer_label = $top_panel/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Server side
	if get_tree().is_network_server():
		$Timer.start()		# Start Time keeping
		# Handle team eliminated signal
		var teams = get_tree().get_nodes_in_group("Team")
		for i in teams:
			i.connect("team_eliminated", self, "S_On_team_eliminated")
		


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
	timer_label.text = String(_min_) + " : " + String(_sec_)


# local function to sync wait time
remotesync func P_syncWaitTime(time : int):
	# Show time remaining in panel
	var time_limit = mode_settings.wait_time
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(_sec_)


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
	if cur_round >= mode_settings.max_rounds:
		# Half time
		if not half_time:
			cur_round = 0
			swapTeam()
			half_time = true
		# Game ends
		else:
			endGame()
			return
			
	respawnEveryone()
	$Timer.start()
	time_elasped = 0
	is_wait_time = true
	freezeEveryone()


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
	pass


# Game ends
func endGame():
	pass



func _on_round_start_dl_timeout():
	unfreezeEveryone()

