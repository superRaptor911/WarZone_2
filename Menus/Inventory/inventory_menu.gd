extends CanvasLayer
var user

#get user
func _ready():
	_get_user()

#move to turret menu and free self
func _on_turrets_pressed():
	get_tree().root.add_child(load("res://Menus/Inventory/turret_menu.tscn").instance())
	queue_free()

#resume player and free self
func _on_close_pressed():
	user.pause_controls(false)
	queue_free()

#get user that called inventory menu
#only network master can call inventory func so,
#user is network master
func _get_user():
	var players = get_tree().get_nodes_in_group("User")
	for p in players:
		if p.is_network_master():
			user = p
			return