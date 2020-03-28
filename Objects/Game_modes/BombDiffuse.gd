extends CanvasLayer

var Round : int = 0
var round_time : int = 150
var level = null

var bomb_scene = preload("res://Objects/Game_modes/BombDiffuse/C4Bomb.tscn")
var bomb
var bomber = null

func _ready():
	if get_tree().is_network_server():
		level = get_tree().get_nodes_in_group("Level")[0]
		level.connect("player_despawned",self,"_on_plyer_despawned")
		#level.connect("bot_despawned",self,"")
		overrideTeamSelector(level)
		
		var bombSites = get_tree().get_nodes_in_group("Bomb_site")
		for i in bombSites:
			i.connect("bomber_entered",self,"_on_bomber_entered_bombSpot")
			i.connect("bomber_left",self,"_on_bomber_exited_bombSpot")
		startRound()

func overrideTeamSelector(lvl):
	var new_teamSelector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
	lvl.teamSelector = new_teamSelector


func _on_plyer_despawned(plr):
	if plr == bomber:
		bomber = null

func selectBomber():
	var actors = get_tree().get_nodes_in_group("Actor")
	var ts = Array()
	for i in actors:
		if i.team.team_id == 0:
			ts.append(i)
	
	if not ts.empty():
		var random_id = randi() % ts.size()
		bomber = ts[random_id]
		bomber.add_to_group("bomber")
		
		if bomb:
			bomb.queue_free()
		bomb = bomb_scene.instance()
		bomb.bomber = bomber
		bomb.connect("bomb_planted",self,"_on_bomb_planted")
		get_tree().root.add_child(bomb)
		
		if bomber.is_in_group("Actor"):
			bomberSelected()
	else:
		print("Not enough players")
		$no_plr_timer.start()

func restartGame():
	Round = 1
	$RoundTimer.start()
	selectBomber()

func startRound():
	Round += 1
	$RoundTimer.start()
	selectBomber()

func endRound():
	var players = get_tree().get_nodes_in_group("User")
	for i in players:
		i.respawn_player()

	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		i.respawnBot()
	
	if bomb:
		bomb.queue_free()
	bomber = null


func _on_bomber_entered_bombSpot():
	if not bomb.bomb_planted:
		showPlantOption(true)

func _on_bomber_exited_bombSpot():
	showPlantOption(false)

func _on_plant_bomb_pressed():
	bomb.activateBomb()

func _on_RoundTimer_timeout():
	#ct win
	endRound()

func _on_bomb_planted():
	bomber.remove_from_group("bomber")
	rpc("bomb_planted")


func _on_no_plr_timer_timeout():
	restartGame()

##########################Remote funcs####################################

func bomberSelected():
	if bomber.is_network_master():
		$Label.popup(1.5)
	else:
		rpc_id(int(bomber.name),"_onBomberSelected")

remote func _onBomberSelected():
	$Label.popup(1.5)


remotesync func bombPlanted():
	$bomb_planted.play()

func showPlantOption(val):
	if bomber.is_network_master():
		$plant_bomb.visible = val
	else:
		rpc_id(int(bomber.name),"_showPlantOption")

remote func _showPlantOption(val):
	$plant_bomb.visible = val
