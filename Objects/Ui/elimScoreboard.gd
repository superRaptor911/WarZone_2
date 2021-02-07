extends Control

var ct_panel = preload("res://Objects/Ui/elimScboard_ct_template.tscn")
var t_panel  = preload("res://Objects/Ui/elimScboard_t_templete.tscn")

onready var ct_list = $Panel/ct/VBoxContainer
onready var t_list  = $Panel/t/VBoxContainer

signal scoreboard_closed

func _ready():
	updateScoreboard()

# Sort by score
class custom_sorter:
	static func sort(a,b) -> bool:
		return a.ref.kills > b.ref.kills

func updateScoreboard():
	var data = game_server._unit_data_list.values()
	data.sort_custom(custom_sorter,"sort")
	
	var ct_panels 	= ct_list.get_children()
	var t_panels 	= t_list.get_children()
	var ct_counter	= 0
	var t_counter	= 0
	var index		= 0
	
	# Fill panels with player data
	for i in data:
		var p_ref  = null
		if i.ref.team.team_id == 0:
			t_counter += 1
			index = t_counter
			if t_counter > t_panels.size():
				p_ref = t_panel.instance()
				t_list.add_child(p_ref)
			else:
				p_ref = t_panels[t_counter - 1]
		else:
			ct_counter += 1
			index = ct_counter
			if ct_counter > ct_panels.size():
				p_ref = ct_panel.instance()
				ct_list.add_child(p_ref)
			else:
				p_ref = ct_panels[ct_counter - 1]
		
		p_ref.get_node("name").text		= i.ref.pname
		p_ref.get_node("score").text 	= String(i.ref.kills)
		p_ref.get_node("deaths").text 	= String(i.ref.deaths)
		p_ref.get_node("index").text 	= String(index)
	
	# Remove Extra panels
	for i in range(t_counter, t_panels.size()):
		t_panels[i].queue_free()
	for i in range(ct_counter, ct_panels.size()):
		ct_panels[i].queue_free()


func _on_Timer_timeout():
	updateScoreboard()


func _on_Button_pressed():
	emit_signal("scoreboard_closed")
