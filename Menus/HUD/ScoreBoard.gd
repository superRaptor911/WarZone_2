extends TextureRect

var dark_panel# = $A/1
var light_panel

func _ready():
	dark_panel = get_node("A/1").duplicate(4)
	light_panel = get_node("A/2").duplicate(4)
	
	get_node("A/1").queue_free()
	get_node("A/2").queue_free()

func setBoardData(data : Array):
	var old_panels = $A.get_children()
	for i in old_panels:
		i.queue_free()

	old_panels = $B.get_children()
	for i in old_panels:
		i.queue_free()
	 
	var teamA_cur_p_clr = "dark"
	var teamB_cur_p_clr = "light"
	
	for i in data:
		print(i.pname)
		if i.team_id == "A":
			var new_panel
			#use alternate colored panel 
			if teamA_cur_p_clr == "dark":
				new_panel = dark_panel.duplicate(4)
				teamA_cur_p_clr = "light"
			else:
				new_panel = light_panel.duplicate(4)
				teamA_cur_p_clr = "dark"
			
			new_panel.get_node("name").text = i.pname
			new_panel.get_node("kills").text = String(i.kills)
			new_panel.get_node("deaths").text = String(i.deaths)
			new_panel.get_node("score").text = String(i.score)
			$A.add_child(new_panel)
		else:
			var new_panel
			#use alternate colored panel 
			if teamB_cur_p_clr == "dark":
				new_panel = dark_panel.duplicate(4)
				teamB_cur_p_clr = "light"
			else:
				new_panel = light_panel.duplicate(4)
				teamB_cur_p_clr = "dark"
			
			new_panel.get_node("name").text = i.pname
			new_panel.get_node("kills").text = String(i.kills)
			new_panel.get_node("deaths").text = String(i.deaths)
			new_panel.get_node("score").text = String(i.score)
			$B.add_child(new_panel)


func _on_ScoreBoard_visibility_changed():
	if visible:
		$Timer.start()


func _on_Timer_timeout():
	hide()
