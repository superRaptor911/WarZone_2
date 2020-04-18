extends Panel

var no_slots = 22

func _ready():
	hide()

class custom_sorter:
	static func sort(a,b) -> bool:
		return a.score > b.score

func setBoardData(data : Array):
	var ts = Array()
	var cts = Array()
	
	data.sort_custom(custom_sorter,"sort")
	
	for i in data:
		#terrorists
		if i.team_id == 0:
			ts.append(i)
		else:
			cts.append(i)
	
	var index = 1
	for i in ts:
		var slot = get_node("T/Plist/s" + String(index))
		slot.show()
		slot.get_node("name").text = i.pname
		slot.get_node("score").text = String(i.score)
		slot.get_node("death").text = String(i.deaths)
		slot.get_node("ping").text = String(i.ping)
		index += 1
	
	for i in range(index , no_slots + 1):
		get_node("T/Plist/s" + String(index)).hide()
		index += 1
	
	index = 1
	for i in cts:
		var slot = get_node("CT/Plist/s" + String(index))
		slot.show()
		slot.get_node("name").text = i.pname
		slot.get_node("score").text = String(i.score)
		slot.get_node("death").text = String(i.deaths)
		slot.get_node("ping").text = String(i.ping)

	for i in range(index , no_slots + 1):
		get_node("CT/Plist/s" + String(index)).hide()
		index += 1


func _on_back_pressed():
	hide()
