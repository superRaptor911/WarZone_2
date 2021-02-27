extends Panel

func setScore(nick : String, score : int, deaths : int, ping = 0):
	get_node("name").text  = nick
	get_node("score").text = String(score)
	get_node("death").text = String(deaths)
	get_node("ping").text  = String(ping)
