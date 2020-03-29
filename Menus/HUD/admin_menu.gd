extends Panel

var panel = preload("res://Menus/HUD/admin_panel.tscn")
var panels = Array()

var max_panels = 8

func _ready():
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.connect("player_spawned",self,"_on_player_joined")
	level.connect("bot_spawned",self,"_on_player_joined")
	
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

	 

func _on_player_joined(plr):
	var pn = panel.instance()
	pn.setPlayer(plr)
	pn.connect("remove_panel",self,"_remove_panel")
	panels.append(pn)
	$VBoxContainer.add_child(pn)

func _remove_panel(pn):
	panels.erase(pn)
	$VBoxContainer.remove_child(pn)


func _on_quit_pressed():
	queue_free()
