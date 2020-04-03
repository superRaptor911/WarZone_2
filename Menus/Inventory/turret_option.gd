extends CanvasLayer
var turret = null
var user
var gun_name

func setup_turret_info(turret_info):
	$panel/panel2/name/Label.text += turret_info.name
	$panel/panel2/type/Label.text += turret_info.type
	$panel/panel2/damage/Label.text += String(turret_info.damage)
	$panel/panel2/ammo/Label.text += String(turret_info.ammo)
	$panel/panel2/cost/Label.text += String(turret_info.cost)
	$panel/panel_cont/desc_panel/Label.text = turret_info.desc
	
func _ready():
	_get_user()
	

func _on_close_pressed():
	get_tree().root.add_child(load("res://Menus/Inventory/turret_menu.tscn").instance())
	queue_free()


func _on_build_pressed():
	game_server.build_turret(gun_name,user.position,user.name)
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