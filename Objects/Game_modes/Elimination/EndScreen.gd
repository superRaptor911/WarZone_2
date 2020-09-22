extends Control

func showScreen():
	var teams = get_tree().get_nodes_in_group("Team")
	# Handle Tie
	if teams[0].score == teams[1].score:
		on_TIE()
		return

	var winning_team = teams[0]
	if winning_team.score < teams[1].score:
		winning_team = teams[1]
	
	var playerList_node = $playerList
	var units = get_tree().get_nodes_in_group("Unit")
	for i in units:
		if i.team.team_id == winning_team.team_id:
			playerList_node.add_item(i.pname)
		
	var local_player_id = String(game_states.player_info.net_id)
	var local_player = game_server._unit_data_list.get(local_player_id)
	if local_player:
		if winning_team.team_id == local_player.ref.team_id:
			$You_win.show()
		else:
			$You_Lost.show()


func on_TIE():
	$playerList.hide()
	$winner_label.hide()
	$Tie.show()

