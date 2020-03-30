extends CanvasLayer

var Round : int = 0
var round_time : int = 150
var level = null

var bomb_scene = preload("res://Objects/Game_modes/BombDiffuse/C4Bomb.tscn")
var bomb = null
var bomber = null

func _ready():
	level = get_tree().get_nodes_in_group("Level")[0]
	overrideTeamSelector(level)
	bomb = bomb_scene.instance()
	level.add_child(bomb)
	
	var teams = get_tree().get_nodes_in_group("Team")
	for i in teams:
		if i.team_id == 0:
			i.team_name = "Terrorist"
		elif i.team_id == 1:
			i.team_name = "Counter Terrorist"
	
	if get_tree().is_network_server():
		bomb.connect("bomb_planted",self,"_on_bomb_planted")
		bomb.connect("bomb_exploded",self,"_on_bomb_exploded")
		level.connect("player_despawned",self,"_on_plyer_despawned")
		#level.connect("bot_despawned",self,"")		
		#connect to bomb sites
		var bombSites = get_tree().get_nodes_in_group("Bomb_site")
		for i in bombSites:
			i.connect("bomber_entered",self,"_on_bomber_entered_bombSpot")
			i.connect("bomber_left",self,"_on_bomber_exited_bombSpot")
		
		
		for t in teams:
			t.connect("team_eliminated",self,"_on_team_eliminated")
			
		startRound()

#set custom team selector 
func overrideTeamSelector(lvl):
	var new_teamSelector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
	lvl.teamSelector = new_teamSelector


#Handle bomber disconnection
func _on_plyer_despawned(plr):
	if plr == bomber:
		bomber = null
		bomb.dropBomb()

#randomly select a bomber from terrorist team
#team id  0 is for terrorist
func selectBomber() -> bool:
	var actors = get_tree().get_nodes_in_group("Actor")
	var ts = Array()
	for i in actors:
		if i.team.team_id == 0:
			ts.append(i)
	
	if not ts.empty():
		var random_id = randi() % ts.size()
		bomber = ts[random_id]
		bomber.add_to_group("bomber")
		bomb.bomber = bomber
		
		if bomber.is_in_group("User"):
			notifyBomber()
		return true
	else:
		print("Not enough players")
	return false


#restart this map reseting all data
#need to reset pinfo
func restartGame():
	if selectBomber():
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
	#respawn everyone
	var players = get_tree().get_nodes_in_group("User")
	for i in players:
		i.respawn_player()

	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		i.respawnBot()
	
	if bomber and bomber.is_in_group("bomber"):
		bomber.remove_from_group("bomber")
	bomber = null


func _on_bomber_entered_bombSpot():
	if not bomb.bomb_planted:
		showPlantOption(true)

func _on_bomber_exited_bombSpot():
	showPlantOption(false)

func _on_plant_bomb_pressed():
	rpc("plantBomb")

func _on_RoundTimer_timeout():
	#ct win
	endRound()

func _on_bomb_planted():
	bomber.remove_from_group("bomber")
	showPlantOption(false)
	rpc("bombPlanted")
	
func _on_bomb_exploded():
	$terrorist_win.play()
	#increse terrorist points
	#####
	$round_end_delay.start()
	

func _on_no_plr_timer_timeout():
	restartGame()

func _on_round_end_delay_timeout():
	endRound()
	startRound()

func _on_round_start_delay_timeout():
	$RoundTimer.start()
	$lets_go.play()


func _on_team_eliminated(team):
	if team.team_id == 1:
		_on_bomb_exploded()

##########################Remote funcs####################################

func notifyBomber():
	if bomber.is_network_master():
		$Label.popup(1.5)
	else:
		rpc_id(int(bomber.name),"_notifyBomber")

remote func _notifyBomber():
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

remotesync func plantBomb():
	bomb.activateBomb()
