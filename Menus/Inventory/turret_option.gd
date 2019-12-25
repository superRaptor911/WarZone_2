extends CanvasLayer
var turret = null

var turret_info = {
	name = "Not set",
	type = "Not_set",
	damage = 0,
	ammo = 0,
	cost = 0
}


func _setup_turret_info():
	if turret:
		turret_info = turret.turret_info
	$panel/panel2/name/Label.text += turret_info.name
	$panel/panel2/type/Label.text += turret_info.type
	$panel/panel2/damage/Label.text += String(turret_info.damage)
	$panel/panel2/ammo/Label.text += String(turret_info.ammo)
	$panel/panel2/cost/Label.text += String(turret_info.cost)
	
func _ready():
	_setup_turret_info()
	