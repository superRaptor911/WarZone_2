extends CanvasLayer

var user
var kill_msg_slots : Kill_Message_slots
var score_board = preload("res://Menus/HUD/ScoreBoard.tscn").instance()
var frames : int = 0

func _ready():
	kill_msg_slots = Kill_Message_slots.new(self,8)
	$fps_timer.start()
	score_board.hide()
	game_server.connect("player_data_synced",self,"updateScoreBoard")
	var GameMode = get_tree().get_nodes_in_group("GameMode")
	if not GameMode.empty():
		if GameMode[0].get("scoreBoard"):
			score_board.queue_free()
			score_board = GameMode[0].scoreBoard
	else:
		print("GameMode not loaded")
	
	add_child(score_board)

func setUser(u):
	user = u
	$reload/gun_s.texture = user.selected_gun.gun_portrait
	$reload/TextureProgress.max_value = user.selected_gun.rounds_in_clip
	$reload/TextureProgress.value =  user.selected_gun.rounds_left

func _process(delta):
	frames += 1
	$reload/TextureProgress.value =  user.selected_gun.rounds_left

func _on_quit_pressed():
	if get_tree().is_network_server():
		network.kick_player(game_states.player_info.net_id,"Disconnected From Server")
	else:
		network.rpc_id(1,"kick_player",game_states.player_info.net_id,"Disconnected From Server")

func _on_pause_pressed():
	$Panel2.show()
	pauseMenuOpenTween()

class MyPlayerSorter:
	static func sort(a, b):
		if a["kills"] < b["kills"]:
			return false
		return true



func _on_score_pressed():
	pauseMenuCloseTween()
	if not get_tree().is_network_server():
		game_server.rpc_id(1,"ServerSyncPlayerDataList",game_states.player_info.net_id)
	else:
		updateScoreBoard()
	score_board.show()

func updateScoreBoard():
	score_board.setBoardData(game_server._player_data_list)

func _on_zoom_pressed():
	if user.selected_gun.current_zoom == user.selected_gun.max_zoom:
		user.selected_gun.current_zoom = 0.75
	else:
		user.selected_gun.current_zoom = min(user.selected_gun.current_zoom + 0.25, user.selected_gun.max_zoom)
	user.get_node("Camera2D").zoom = Vector2(user.selected_gun.current_zoom,user.selected_gun.current_zoom)

func _on_HE_pressed():
	user.throwGrenade()

class Message_slot:
	var is_free : bool
	var msg : String
	
	func _init():
		is_free = true
		
	func clear_slot():
		msg = ""
		is_free = true
	
	func addMessage(_msg):
		msg = _msg
		is_free = false
	

class Kill_Message_slots:
	var msg_slots : Array
	var timer : Timer
	var active_slots : int
	var max_slots
	var hud
	
	func _init(usr,num = 8):
		hud = usr
		active_slots = 0
		max_slots = num
		for i in range(0,num):
			msg_slots.append(Message_slot.new())
		timer = Timer.new()
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.connect("timeout",self,"_on_timeout")
		usr.add_child(timer)
	
	func _on_timeout():
		if active_slots:
			active_slots -= 1
			for i in range(active_slots):
				msg_slots[i].addMessage(msg_slots[i + 1].msg)
				msg_slots[i + 1].clear_slot()
			timer.start()
			showKillMsg()
	
	func forceRemove():
		active_slots -= 1
		for i in range(active_slots):
			msg_slots[i].addMessage(msg_slots[i + 1].msg)
			msg_slots[i + 1].clear_slot()
		

	func addKillMessage(msg):
		if not active_slots:
			timer.start()
			
		active_slots += 1
		if active_slots > max_slots:
			active_slots = max_slots
			forceRemove()
			active_slots += 1
		
		msg_slots[active_slots - 1].addMessage(msg)
		showKillMsg()
	
	func showKillMsg():
		var labels = hud.get_node("kill_msg")
		for i in range(active_slots):
			labels.get_node(String(i + 1)).text = msg_slots[i].msg
		for i in range(active_slots,max_slots):
			labels.get_node(String(i + 1)).text = ""
		

func addKillMessage(msg):
	kill_msg_slots.addKillMessage(msg)


func _on_nextGun_pressed():
	user.rpc("switchGun")
	$reload/gun_s.texture = user.selected_gun.gun_portrait
	$reload/TextureProgress.max_value = user.selected_gun.rounds_in_clip
	$reload/TextureProgress.value =  user.selected_gun.rounds_left


func _on_btn_pressed():
	user.selected_gun.reload()

func _on_back_pressed():
	pauseMenuCloseTween()


func _on_admin_menu_pressed():
	pauseMenuCloseTween()
	var admin_menu = load("res://Menus/HUD/admin_menu.tscn").instance()
	add_child(admin_menu)


func _on_fps_timer_timeout():
	$fps.text = String(frames)
	frames = 0

############################Tweeennnnnning##################################

func pauseMenuOpenTween():
	$Panel2.rect_pivot_offset = $Panel2.rect_size / 2
	$Tween.remove_all()
	$Panel2.rect_scale = Vector2(0.01,0.01)
	$Tween.interpolate_property($Panel2,"rect_scale",$Panel2.rect_scale,
		Vector2(1,1),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func pauseMenuCloseTween():
	$Tween.remove_all()
	$Tween.interpolate_property($Panel2,"rect_scale",$Panel2.rect_scale,
		Vector2(0.01,0.01),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($Panel2,"visible",true,false,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()


