extends Panel

var panel = preload("res://Menus/HUD/admin_panel.tscn")
var panels = Array()

var cur_panel = 0
var max_panels = 8

func _ready():
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.connect("player_created",self,"_on_player_joined")
	level.connect("bot_created",self,"_on_player_joined")
	
	var players = get_tree().get_nodes_in_group("Unit")
	
	var index = 0
	for i in players:
		index += 1
		var pn = panel.instance()
		pn.setPlayer(i)
		pn.get_node("sno").text = String(index)
		pn.connect("remove_panel",self,"_remove_panel")
		panels.append(pn)
		if index <= 8:
			$VBoxContainer.add_child(pn)
	
	$VSlider.max_value = max(panels.size() - 8, 0)
	$VSlider.value = 0

	 

func _on_player_joined(plr):
	var pn = panel.instance()
	pn.setPlayer(plr)
	pn.connect("remove_panel",self,"_remove_panel")
	panels.append(pn)
	$VBoxContainer.add_child(pn)
	$VSlider.max_value = max(panels.size() - 8, 0)
	$VSlider.value = min($VSlider.max_value,$VSlider.value)

func _remove_panel(pn):
	panels.erase(pn)
	$VBoxContainer.remove_child(pn)
	_on_VSlider_value_changed(cur_panel)


func _on_quit_pressed():
	MusicMan.click()
	queue_free()


func _on_VSlider_value_changed(value):
	cur_panel = value
	var vbox = $VBoxContainer
	var old_panels = vbox.get_children()
	for i in old_panels:
		vbox.remove_child(i)
	
	var max_p = min(value + max_panels,panels.size())
	for i in range(value,max_p):
		vbox.add_child(panels[i])
