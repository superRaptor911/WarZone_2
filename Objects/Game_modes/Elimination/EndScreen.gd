extends Control

func showWinners():
	var teams = get_tree().get_nodes_in_group("Team")
	# Handle Tie
	if teams[0].score == teams[1].score:
		on_TIE()
		return

	var winning_team = teams[0]
	if winning_team.score < teams[1].score:
		winning_team = teams[1]
	
	var units = get_tree().get_nodes_in_group("Unit")
	for i in units:
		if i.team.team_id == winning_team.team_id:
			$playerList.add_item(i.pname)


func on_TIE():
	pass
