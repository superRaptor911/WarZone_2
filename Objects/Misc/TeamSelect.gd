extends CanvasLayer

var selected_btn = null
signal spectate_mode

func _on_spec_pressed():
	if selected_btn:
		if selected_btn != $TeamSelect/container/spec:
			$TeamSelect/container/spec.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $TeamSelect/container/spec
			changePanelTween("spec_panel")
	else:
		selected_btn = $TeamSelect/container/spec
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("spec_panel")


func _on_quit_pressed():
	if selected_btn:
		if selected_btn != $TeamSelect/container/quit:
			$TeamSelect/container/quit.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $TeamSelect/container/quit
			changePanelTween("exit_panel")
	else:
		selected_btn = $TeamSelect/container/quit
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("exit_panel")

func _on_Button_pressed():
	if get_tree().is_network_server():
		network.kick_player(game_states.player_info.net_id,"Disconnected From Server")
	else:
		network.rpc_id(1,"kick_player",game_states.player_info.net_id,"Disconnected From Server")

########################Tweeeeening#######################################

var selected_panel = null
onready var panel_pos = $TeamSelect/panel_pos.position

func changePanelTween(node_name : String):
	var node = get_node("TeamSelect/" + node_name)
	
	if not node:
		print("Error Node not found")
		return
		
	if node == selected_panel:
		print("Error same node")
		return
	
	var delay = 0.0
	$TeamSelect/Tween.remove_all()
	if selected_panel:
		delay = 0.2
		selected_panel.rect_position = panel_pos
		$TeamSelect/Tween.interpolate_property(selected_panel,"rect_position",selected_panel.rect_position,
			selected_panel.rect_position + Vector2(670,0),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	
	node.rect_position = panel_pos - Vector2(0,550)
	$TeamSelect/Tween.interpolate_property(node,"rect_position",node.rect_position,panel_pos,
		0.5,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	selected_panel = node
	$TeamSelect/Tween.start()


func _on_spec_Button_pressed():
	emit_signal("spectate_mode")
