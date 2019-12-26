extends TextureButton
signal close_this
export var main_gun_name : String
export var turret_desc : String

var turret_info = {
	name = "Not set",
	type = "Not_set",
	damage = 0,
	ammo = 0,
	cost = 0,
	desc = "Not set"
}

func _set_turret_info(gun):
	turret_info.name = main_gun_name
	turret_info.type = main_gun_name + " Turret"
	turret_info.damage = gun.damage
	turret_info.ammo = 350
	turret_info.cost = 1000
	turret_info.desc = turret_desc
	

func _on_pressed():
	var turret_gun = game_states.weaponResource.get(main_gun_name).instance()
	_set_turret_info(turret_gun)
	var turret_build_menu = load("res://Menus/Inventory/turret_option.tscn").instance()
	turret_build_menu.setup_turret_info(turret_info)
	turret_build_menu.gun_name = main_gun_name
	get_tree().root.add_child(turret_build_menu)
	emit_signal("close_this")

func _ready():
	connect("pressed",self,"_on_pressed")