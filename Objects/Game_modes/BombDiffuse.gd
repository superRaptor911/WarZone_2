extends CanvasLayer

var Round : int = 0
var round_time : int = 150
var level = null
var local_player = null

var bomb_scene = preload("res://Objects/Game_modes/BombDiffuse/C4Bomb.tscn")
var bomb = null
var bomber = null

var bomb_planted = false
var bomb_diffused = false

var time_to_plant = 4.0
var planting_bomb = false

var time_to_diffuse = 5.0
var diffusing_bomb = false

signal round_started
signal round_end
signal bomber_bot(bot)
signal bomb_planted

func _ready():
	$plant_bomb/ProgressBar.max_value = time_to_plant
	$diffuse_button/ProgressBar.max_value = time_to_diffuse
	level = get_tree().get_nodes_in_group("Level")[0]
	overrideTeamSelectorFor(level)
	bomb = bomb_scene.instance()
	level.add_child(bomb)
	level.connect("player_spawned",self,"getLocalPlayer")
	
	var teams = get_tree().get_nodes_in_group("Team")
	for i in teams:
		if i.team_id == 0:
			i.team_name = "Terrorist"
		elif i.team_id == 1:
			i.team_name = "Counter Terrorist"
	
	if get_tree().is_network_server():
		bomb.connect("bomb_planted",self,"_on_bomb_planted")
		bomb.connect("bomb_exploded",self,"terroristWin")
		bomb.connect("bomb_diffuser",self,"_bomb_diffuser_diffusing")
		bomb.connect("bomb_diffuser_left",self,"_bomb_diffuser_not_diffusing")
		
		level.connect("player_spawned",self,"_on_player_spawnwed")
		level.connect("bot_spawned",self,"_on_player_spawnwed")
		level.connect("player_despawned",self,"_on_plyer_despawned")
		level.connect("bot_despawned",self,"_on_plyer_despawned")
		#connect to bomb sites
		var bombSites = get_tree().get_nodes_in_group("Bomb_site")
		for i in bombSites:
			i.connect("bomber_entered",self,"_on_bomber_entered_bombSpot")
			i.connect("bomber_left",self,"_on_bomber_exited_bombSpot")
		
		for t in teams:
			t.connect("team_eliminated",self,"_on_team_eliminated")


#set custom team selector 
func overrideTeamSelectorFor(lvl):
	var new_teamSelector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
	lvl.teamSelector = new_teamSelector

func getLocalPlayer(plr):
	if plr.is_network_master():
		local_player = plr

func _on_player_spawnwed(plr):
	if plr.team.player_count == 1:
		print("restarting game")
		restartGame()
		return

	if not $RoundTimer.is_stopped():
		plr.killChar()

#Handle bomber disconnection
func _on_plyer_despawned(plr):
	if plr == bomber:
		removeBomber()
	if plr == bomb.diffuser:
		_bomb_diffuser_not_diffusing()


#randomly select a bomber from terrorist team
#team id  0 is for terrorist
func selectBomber() -> bool:
	#safety chk
	if bomber and bomber.is_in_group("bomber"):
		bomber.remove_from_group("bomber")
	
	#unit is (player and bot)
	var actors = get_tree().get_nodes_in_group("Unit")
	var ts = Array()
	for i in actors:
		if i.alive and i.team.team_id == 0:
			ts.append(i)
	
	#if terrorists select a bomeber
	if not ts.empty():
		var random_id = randi() % ts.size()
		bomber = ts[random_id]
		bomber.add_to_group("bomber")
		bomber.connect("char_killed",self,"removeBomber")
		bomb.setBomber(bomber)
		
		if bomber.is_in_group("User"):
			rpc_id(int(bomber.name),"_notifyBomber")
		else:
			bomber.is_bomber = true
		return true
	else:
		print("Not enough players")
	return false


func removeBomber():
	if bomber:
		print("bomber killed")
		bomber.remove_from_group("bomber")
		bomber.disconnect("char_killed",self,"removeBomber")
		bomb.dropBomb()
		if bomber.is_in_group("Bot"):
			bomber.is_bomber = false
			bomber.is_on_bomb_site = false
		
		bomber = null


func respawnEveryOne():
	var players = get_tree().get_nodes_in_group("User")
	for i in players:
		i.respawn_player()

	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		i.respawnBot()


#restart this map reseting all data
#need to reset pinfo
func restartGame():
	removeBomber()
	if selectBomber():
		respawnEveryOne()
		Round = 1
		$round_start_delay.start()
	else:
		$no_plr_timer.start()
	
#start new round
func startRound():
	if selectBomber():
		Round += 1
		$round_start_delay.start()
	else:
		$no_plr_timer.start()

#end current round
#its like a destructor for rounds
func endRound():
	respawnEveryOne()
	removeBomber()
	bomb_planted = false
	bomb_diffused = false
	
	if bomb.bomb_planted:
		bomb.resetBomb()


func _bomb_diffuser_diffusing():
	bomb.diffuser.connect("char_killed",self,"_on_diffuser_killed")
	if bomb.diffuser.is_in_group("User"):
		rpc_id(int(bomb.diffuser.name),"_showDiffuseOption",true)

func _bomb_diffuser_not_diffusing():
	if bomb.diffuser:
		bomb.diffuser.disconnect("char_killed",self,"_on_diffuser_killed")
		if bomb.diffuser.is_in_group("User"):
			rpc_id(int(bomb.diffuser.name),"_showDiffuseOption",false)

func _on_diffuser_killed():
	bomb.diffuser.disconnect("char_killed",self,"_on_diffuser_killed")
	if bomb.diffuser.is_in_group("User"):
		rpc_id(int(bomb.diffuser.name),"_showDiffuseOption",false)
	bomb.diffuser = null

func _on_bomber_entered_bombSpot():
	if not bomb.bomb_planted and bomber.is_in_group("User"):
		showPlantOption(true)
	else:
		bomber.is_on_bomb_site = true

func _on_bomber_exited_bombSpot():
	if bomber.is_in_group("User"):
		showPlantOption(false)
	else:
		bomber.is_on_bomb_site = false


func _on_plant_bomb_pressed():
	rpc("_plantBomb")

func _on_RoundTimer_timeout():
	counterTerroistWin()
	endRound()

func _on_bomb_planted():
	bomb_planted = true
	showPlantOption(false)
	rpc("bombPlanted")
	removeBomber()
	emit_signal("bomb_planted")


func terroristWin():
	$round_end_delay.start()
	rpc("_terroristWin")


func counterTerroistWin():
	$round_end_delay.start()
	rpc("_counterTerroistWin")

func _on_no_plr_timer_timeout():
	restartGame()

func _on_round_end_delay_timeout():
	endRound()
	startRound()

func _on_round_start_delay_timeout():
	$RoundTimer.start()
	emit_signal("round_started")
	rpc("_roundStart")


func _on_team_eliminated(team):
	if team.team_id == 1:
		terroristWin()
	elif team.team_id == 0:
		if not bomb_planted or bomb_diffused:
			counterTerroistWin()


func _on_plant_bomb_button_down():
	#$plant_bomb.show()
	$plant_bomb/ProgressBar.value = 0
	planting_bomb = true


func _on_plant_bomb_button_up():
	$plant_bomb/ProgressBar.value = 0
	planting_bomb = false
	

func _on_diffuse_button_button_down():
	$diffuse_button/ProgressBar.value = 0
	diffusing_bomb = true


func _on_diffuse_button_button_up():
	$diffuse_button/ProgressBar.value = 0
	diffusing_bomb = false


func _process(delta):
	if planting_bomb:
		$plant_bomb/ProgressBar.value += delta
		if $plant_bomb/ProgressBar.value == time_to_plant:
			planting_bomb = false
			$plant_bomb.hide()
			$plant_bomb/ProgressBar.value = 0
			rpc("_plantBomb")
	
	if diffusing_bomb:
		$diffuse_button/ProgressBar.value += delta
		if $diffuse_button/ProgressBar.value == time_to_diffuse:
			diffusing_bomb = false
			$diffuse_button.hide()
			$diffuse_button/ProgressBar.value = 0
			rpc("_bombDiffused")

##########################Remote funcs####################################

remotesync func _notifyBomber():
	$Label.popup(1.5)


remotesync func bombPlanted():
	$bomb_planted.play()

func showPlantOption(val):
	if bomber.is_network_master():
		$plant_bomb.visible = val
	else:
		rpc_id(int(bomber.name),"_showPlantOption",val)

remote func _showPlantOption(val):
	$plant_bomb.visible = val

remotesync func _showDiffuseOption(val):
	$diffuse_button.visible = val


remotesync func _plantBomb():
	bomb.activateBomb()

remotesync func _freezePlayer(val):
	if local_player:
		local_player.pause_controls(val)

remotesync func _counterTerroistWin():
	$counterterrorist_win.play()

remotesync func _terroristWin():
	$terrorist_win.play()

remotesync func _roundStart():
	$lets_go.play()

remotesync func _bombDiffused():
	if get_tree().is_network_server():
		$round_end_delay.start()
		_bomb_diffuser_not_diffusing()
	bomb.diffuseBomb()
	$bomb_diffused.play()
