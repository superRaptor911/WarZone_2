extends Panel

signal scoreboard_closed

var red = Color8(222, 74, 23)
var green = Color8(27, 148, 10)
var max_slots = 7


class custom_sorter:
	static func sort(a,b) -> bool:
		return a.ref.score > b.ref.score

func setBoardData(data_dict : Dictionary):
	var data = data_dict.values()
	
	data.sort_custom(custom_sorter,"sort")
	
	var index = 0
	# Hide all slots
	for _i in range(index , max_slots):
		get_node("Panel/VBoxContainer/f" + String(index)).hide()
		index += 1
	
	index = 0
	for i in data:
		var slot = get_node("Panel/VBoxContainer/f" + String(index))
		#terrorists
		if i.ref.team.team_id == 0:
			slot.self_modulate = red
		# Counter-terrorist
		else:
			slot.self_modulate = green
		# Set data
		slot.show()
		slot.get_node("name").text = i.ref.pname
		slot.get_node("score").text = String(i.ref.score)
		slot.get_node("kills").text = String(i.ref.kills)
		slot.get_node("deaths").text = String(i.ref.deaths)
		slot.get_node("ping").text = String(i.ref.ping)
		index += 1
		
		if index == max_slots:
			break

func _on_back_pressed():
	emit_signal("scoreboard_closed")
