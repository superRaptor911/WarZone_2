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

func _ready():
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
		
		level.connect("player_spawned",self,"_on_player_spawnwed")
		level.connect("player_despawned",self,"_on_plyer_despawned")
		#level.connect("bot_despawned",self,"")		
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
		bomber = null
		bomb.dropBomb()

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
	
	if not ts.empty():
		var random_id = randi() % ts.size()
		bomber = ts[random_id]
		bomber.add_to_group("bomber")
		bomb.bomber = bomber
		
		if bomber.is_in_group("User"):
			rpc_id(int(bomber.name),"_notifyBomber")
		return true
	else:
		print("Not enough players")
	return false


func respawnEveryOne():
	var teams = get_tree().get_nodes_in_group("Team")
	for i in teams:
		i.resetAliveData()
	
	var players = get_tree().get_nodes_in_group("User")
	for i in players:
		i.respawn_player()

	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		i.respawnBot()


#restart this map reseting all data
#need to reset pinfo
func restartGame():
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
	if bomber and bomber.is_in_group("bomber"):
		bomber.remove_from_group("bomber")
	bomber = null


func _on_bomber_entered_bombSpot():
	if not bomb.bomb_planted:
		showPlantOption(true)

func _on_bomber_exited_bombSpot():
	showPlantOption(false)

func _on_plant_bomb_pressed():
	rpc("_plantBomb")

func _on_RoundTimer_timeout():
	counterTerroistWin()
	endRound()

func _on_bomb_planted():
	bomb_planted = true
	bomber.remove_from_group("bomber")
	showPlantOption(false)
	rpc("bombPlanted")


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
	rpc("_roundStart")


func _on_team_eliminated(team):
	if team.team_id == 1:
		terroristWin()
	elif team.team_id == 0:
		if not bomb_planted or bomb_diffused:
			counterTerroistWin()

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
