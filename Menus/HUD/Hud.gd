extends CanvasLayer

var user
var ini_pause_posi : Vector2

func _ready():
	ini_pause_posi = $Panel2.rect_global_position
	$Panel2.rect_global_position = Vector2(-500,-500)
	if not game_states.is_android:
		$melee.queue_free()
		$reload.queue_free()
		$HE.queue_free()

func setUser(u):
	user = u
	$Panel/ammo.text = String( user.selected_gun.rounds_left) + "|" + String(user.selected_gun.clips)

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

func _on_zoom_pressed():
	if user.selected_gun.current_zoom == user.selected_gun.max_zoom:
		user.selected_gun.current_zoom = 0.75
	else:
		user.selected_gun.current_zoom = min(user.selected_gun.current_zoom + 0.25, user.selected_gun.max_zoom)
	user.get_node("Camera2D").zoom = Vector2(user.selected_gun.current_zoom,user.selected_gun.current_zoom)

func _on_HE_pressed():
	user.throwGrenade()
