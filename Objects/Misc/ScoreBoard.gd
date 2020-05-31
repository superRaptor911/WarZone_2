extends Panel

signal scoreboard_closed

var no_slots = 22


class custom_sorter:
	static func sort(a,b) -> bool:
		return a.ref.score > b.ref.score

func setBoardData(data_dict : Dictionary):
	var data = data_dict.values()
	var ts = Array()
	var cts = Array()
	
	data.sort_custom(custom_sorter,"sort")
	
	for i in data:
		#terrorists
		if i.ref.team.team_id == 0:
			ts.append(i)
		else:
			cts.append(i)
	
	var index = 1
	for i in ts:
		var slot = get_node("T/Plist/s" + String(index))
		slot.show()
		slot.get_node("name").text = i.ref.pname
		slot.get_node("score").text = String(i.ref.score)
		slot.get_node("death").text = String(i.ref.deaths)
		slot.get_node("ping").text = String(i.ref.ping)
		index += 1
	
	for _i in range(index , no_slots + 1):
		get_node("T/Plist/s" + String(index)).hide()
		index += 1
	
	index = 1
	for i in cts:
		var slot = get_node("CT/Plist/s" + String(index))
		slot.show()
		slot.get_node("name").text = i.ref.pname
		slot.get_node("score").text = String(i.ref.score)
		slot.get_node("death").text = String(i.ref.deaths)
		slot.get_node("ping").text = String(i.ref.ping)
		index += 1

	for _i in range(index , no_slots + 1):
		get_node("CT/Plist/s" + String(index)).hide()
		index += 1


func _on_back_pressed():
	emit_signal("scoreboard_closed")
