extends CanvasLayer

var user
var ini_pause_posi : Vector2
var kill_msg_slots : Kill_Message_slots
var score_board = preload("res://Menus/HUD/ScoreBoard.tscn").instance()

func _ready():
	ini_pause_posi = $Panel2.rect_global_position
	$Panel2.rect_global_position = Vector2(-500,-500)
	kill_msg_slots = Kill_Message_slots.new(self,8)
	score_board.hide()
	game_server.connect("player_data_synced",self,"updateScoreBoard")
	add_child(score_board)

func setUser(u):
	user = u
	$Panel/ammo.text = String( user.selected_gun.rounds_left) + "|" + String(user.selected_gun.clips)
	$reload/gun_s.texture = user.selected_gun.gun_portrait

func _process(delta):
	$Panel/ammo.text = String( user.selected_gun.rounds_left) + "|" + String(user.selected_gun.clips)

func _on_reload_pressed():
	user.selected_gun.reload()


func _on_quit_pressed():
	if get_tree().is_network_server():
		network.kick_player(game_states.player_info.net_id,"Disconnected From Server")
	else:
		network.rpc_id(1,"kick_player",game_states.player_info.net_id,"Disconnected From Server")
	
var pause_counter : bool = false

func _on_pause_pressed():
	pause_counter = !pause_counter
	if pause_counter:
		$Panel2.rect_global_position = ini_pause_posi
	else:
		$Panel2.rect_global_position = Vector2(-500,-500)

class MyPlayerSorter:
	static func sort(a, b):
		if a["kills"] < b["kills"]:
			return false
		return true



func _on_score_pressed():
	pause_counter = !pause_counter
	if pause_counter:
		$Panel2.rect_global_position = ini_pause_posi
	else:
		$Panel2.rect_global_position = Vector2(-500,-500)
	
	if not get_tree().is_network_server():
		game_server.rpc_id(1,"ServerSyncPlayerDataList",game_states.player_info.net_id)
	else:
		updateScoreBoard()
	score_board.show()
	$Tween.interpolate_property(score_board, "modulate", Color8(255,255,255,255),Color8(255,255,255,0), 4.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	return
	
	var players = get_tree().get_nodes_in_group("User")
	var player_array = Array()
	for p in players:
		player_array.append({"name" : p.pname,"kills" : p.kills,"deaths" : p.deaths})
	player_array.sort_custom(MyPlayerSorter,"sort")
	
	var font = load("res://font.tres")
	
	#clean up previous chart
	var childs = $GridContainer.get_children()
	var cu : int = 0
	for c in childs:
		if cu >= 3:
			$GridContainer.remove_child(c)
			c.queue_free()
		cu += 1
	
	for p in player_array:
		var l = Label.new()
		l.add_font_override("font",font)
		l.text = p["name"]
		var l1 = Label.new()
		l1.add_font_override("font",font)
		l1.text = String(p["kills"])
		var l2 = Label.new()
		l2.add_font_override("font",font)
		l2.text = String(p["deaths"])
		$GridContainer.add_child(l)
		$GridContainer.add_child(l1)
		$GridContainer.add_child(l2)
	$Tween.interpolate_property($GridContainer, "modulate", Color8(255,255,255,255),Color8(255,255,255,0), 4.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

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
