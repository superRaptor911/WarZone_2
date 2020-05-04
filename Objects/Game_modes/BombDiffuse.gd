extends CanvasLayer

var Round : int = 0
var round_time : int = 0
var level = null

var end_screen_scn = preload("res://Objects/Game_modes/endScreen.tscn")
var bomb_scene = preload("res://Objects/Game_modes/BombDiffuse/C4Bomb.tscn")
var bomb = null
var bomber = null
var diffuser = null
var bomb_diffused = false
var time_elapsed = 0


var terrorist_team
var counter_t_team

#signals for bot
signal round_started
signal bomb_planted
signal bomber_selected(plr)
signal bomber_killed


func _ready():
	#server side
	if get_tree().is_network_server():
		round_time = game_server.extraServerInfo.round_time * 60
		$oneTimer.start()
		
		#get team and connect signals
		var teams = get_tree().get_nodes_in_group("Team")
		if teams[0].team_id == 0:
			terrorist_team = teams[0]
			counter_t_team = teams[1]
		else:
			terrorist_team = teams[1]
			counter_t_team = teams[0]
		for i in teams:
			i.connect("team_eliminated",self,"S_onTeamEliminated")
		
		#connect signals
		level = get_tree().get_nodes_in_group("Level")[0]
		level.connect("player_despawned",self,"S_handleDisconnection")
		level.connect("bot_despawned",self,"S_handleDisconnection")
		level.connect("player_spawned",self,"S_on_player_joined")
		level.connect("bot_spawned",self,"S_on_player_joined")
		
		#handle bomb site signals
		var bomb_sites = get_tree().get_nodes_in_group("Bomb_site")
		for i in bomb_sites:
			i.connect("bomber_entered",self,"_on_bomber_enters_bomb_site")
			i.connect("bomber_left",self,"_on_bomber_leaves_bomb_site")


func S_on_player_joined(plr):
	#if team was empty before restart round
	if plr.team.player_count == 1:
		$round_end_delay.start()


#server side
func S_startRound():
	emit_signal("round_started")
	bomb_diffused = false
	respawnEveryOne()
	#update counters
	time_elapsed = 0
	Round += 1
	#start time keeping
	$oneTimer.start()
	#load bomb
	if bomb:
		print_debug("Error : bomb already exist")
	var bname = "C4" + String(randi() % 999999)
	rpc("loadBomb",bname)
	#select bomber
	S_selectBomber()


remotesync func loadBomb(bomb_name):
	if bomb:
		print_debug("Error : bomb already exist")
		bomb.queue_free()
	bomb = bomb_scene.instance()
	bomb.name = bomb_name
	var lvl = get_tree().get_nodes_in_group("Level")[0]
	lvl.add_child(bomb)
	bomb.connect("bomb_planted",self,"_on_bomb_planted")

	#connect local signal
	bomb.connect("diffuser_entered",self,"_on_ct_in_diffuse_range")
	bomb.connect("diffuser_left",self,"_on_ct_out_of_diffuse_range")
	#connect server signal
	if get_tree().is_network_server():
		bomb.connect("bomb_planted",self,"S_onBombPlanted")
		bomb.connect("bomb_exploded",self,"S_bombExploded")



func respawnEveryOne():
	var players = get_tree().get_nodes_in_group("User")
	for i in players:
		i.respawn_player()

	var bots = get_tree().get_nodes_in_group("Bot")
	for i in bots:
		i.respawnBot()


func S_endRound():
	if (max(terrorist_team.score,counter_t_team.score) >=
		 game_server.extraServerInfo.max_wins):
			
			return
	S_startRound()


remotesync func sync_endGame():
	var end_scr = end_screen_scn.instance()
	if get_tree().is_network_server():
		end_scr.connect("ok",self,"restartGameMode")
	add_child(end_scr)
	end_scr.rect_scale = Vector2(0,0)
	$Tween.interpolate_property(get_tree().get_nodes_in_group("Level")[0],"modulate",
		Color8(255,255,255,255),Color8(0,0,0,0),2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.interpolate_property(end_scr,"rect_scale",Vector2(0,0),Vector2(1,1),1,
		Tween.TRANS_QUAD,Tween.EASE_OUT,2)
	$Tween.start()
	$info.hide()


func restartGameMode():
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.Server_startLevel()
	$Tween.interpolate_property(level,"modulate",Color8(0,0,0,0),Color8(255,255,255,255),
		2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()


#time keping timer
#updates every one second
func _on_oneTimer_timeout():
	time_elapsed += 1
	#round time ended and ct win
	if time_elapsed > round_time:
		$oneTimer.stop()
		$round_end_delay.start()
		_on_counter_terrorist_win()
	rpc("syncTime",time_elapsed)


remotesync func syncTime(time_now):
	var time_left : int = round_time - time_now
	var _min : int = time_left / 60
	var _sec : int = time_left % 60
	$info/time_left.text = String(_min) + ":" + String(_sec)


func _on_round_end_delay_timeout():
	S_endRound()


#this method selects bomber from terrorist team
func S_selectBomber():
	if terrorist_team.player_count > 0:
		var players = Array()
		#give C4 to human player
		if (game_server.extraServerInfo.bot_differ_to_user 
			and (terrorist_team.user_count > 0)):
			var Hplayers = get_tree().get_nodes_in_group("User")
			for i in Hplayers:
				if i.team.team_id == 0:
					players.append(i)
		else:
			var all_players = get_tree().get_nodes_in_group("Unit")
			for i in all_players:
				if i.team.team_id == 0:
					players.append(i)
		
		var chosen_one = players[randi() % players.size()]
		chosen_one.connect("char_killed",self,"S_onBomberKilled")
		chosen_one.add_to_group("bomber")
		bomber = chosen_one
		bomb.usr = bomber.name
		
		#Tell player that he/she was chosen
		if bomber.is_in_group("User"):
			rpc_id(int(bomber.name),"notifyBomber")
		emit_signal("bomber_selected",bomber)
	else:
		print("No players in terrorist")


remotesync func notifyBomber():
	$popup.popup(2.5)


func S_handleDisconnection(plr):
	#bomber disconnected
	if plr == bomber:
		bomb.dropBomb(bomber.position)


func S_onBomberKilled():
	#disconnect this signal and group
	bomber.disconnect("char_killed",self,"S_onBomberKilled")
	bomber.remove_from_group("bomber")
	#drop bomb #remote function no need to sync
	bomb.dropBomb(bomber.position)
	emit_signal("bomber_killed")


func S_onTeamEliminated(team):
	if team.team_id == 0 and bomb.bomb_planted:
		return
	#stop timer
	$oneTimer.stop()
	#terrorists eliminated
	if team.team_id == 0:
		_on_counter_terrorist_win()
	#counter terrorist eliminated
	else:
		_on_terrorist_win()


func _on_terrorist_win():
	rpc("terroristWin")
	terrorist_team.score += 1
	$round_end_delay.start()
	rpc("syncScore",terrorist_team.score, counter_t_team.score)


remotesync func terroristWin():
	$terrorist_win.play()


func _on_counter_terrorist_win(bomb_diff = false):
	rpc("counterTerroristWin",bomb_diff)
	counter_t_team.score += 1
	$round_end_delay.start()
	rpc("syncScore",terrorist_team.score, counter_t_team.score)


remotesync func counterTerroristWin(bomb_diff):
	if bomb_diff:
		$bomb_diffused.play()
	$counterterrorist_win.play()
	

remotesync func syncScore(t,ct):
	$info/T/pts.text = String(t)
	$info/CT/pts.text = String(ct)


func S_onBombPlanted():
	$oneTimer.stop()
	emit_signal("bomb_planted")

#called remotely by c4
func _on_bomb_planted():
	$bomb_planted.play()
	$info/time_left.text = "0:0"



func _on_bomber_enters_bomb_site():
	if bomber.is_in_group("User"):
		rpc_id(int(bomber.name),"showPlantButton",true)


func _on_bomber_leaves_bomb_site():
	if bomber.is_in_group("User"):
		rpc_id(int(bomber.name),"showPlantButton",false)


remotesync func showPlantButton(val):
	$plant_bomb.visible = val



var plant_button_pressed = false
var diffuse_btn_pressed = false


#remote method
func _on_plant_bomb_button_down():
	plant_button_pressed = true
	$plant_bomb/ProgressBar.value = 0

#remote method
func _on_plant_bomb_button_up():
	plant_button_pressed = false
	$plant_bomb/ProgressBar.value = 0

#remote method
func _process(delta):
	if plant_button_pressed:
		$plant_bomb/ProgressBar.value += delta 
		if $plant_bomb/ProgressBar.value == $plant_bomb/ProgressBar.max_value:
			plant_button_pressed = false
			$plant_bomb.hide()
			#tell server that peer planted bomb
			rpc_id(1,"S_peerPlantedBomb")
	if diffuse_btn_pressed:
		var bar = $diffuse_btn/ProgressBar
		bar.value += delta
		if bar.value == bar.max_value:
			diffuse_btn_pressed = false
			$diffuse_btn.hide()
			rpc_id(1,"S_peerDiffusedBomb")


#server only
remotesync func S_peerPlantedBomb():
	bomb.activateBomb(bomber.position)
	bomber.disconnect("char_killed",self,"S_onBomberKilled")
	bomber.remove_from_group("bomber")
	bomber = null
	rpc("bombPlanted")


remotesync func bombPlanted():
	$bomb_planted.play()


#Terrorist wins when bomb explodes
func S_bombExploded():
	_on_terrorist_win()



func _on_diffuse_btn_button_down():
	diffuse_btn_pressed = true
	$diffuse_btn/ProgressBar.value = 0


func _on_diffuse_btn_button_up():
	diffuse_btn_pressed = false
	$diffuse_btn/ProgressBar.value = 0


#local method
func _on_ct_in_diffuse_range(ct):
	if ct.is_in_group("User"):
		$diffuse_btn.show()

#local method
func _on_ct_out_of_diffuse_range(ct):
	if ct.is_in_group("User"):
		$diffuse_btn.hide()


remotesync func S_peerDiffusedBomb():
	if not bomb_diffused:
		bomb.diffuseBomb()
		bomb_diffused = true
		_on_counter_terrorist_win(true)
