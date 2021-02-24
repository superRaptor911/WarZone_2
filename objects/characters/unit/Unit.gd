extends "res://objects/characters/entity/Entity.gd"

var gun_1 = null
var gun_2 = null
var cur_gun = null

func equipGun(gun_name : String):
	var resource = get_tree().root.get_node("Resources")
	if !gun_1:
		gun_1 = resource.guns.get(gun_name).instance()
		gun_1.init(name)
		switchToGun(gun_1)
	elif !gun_2:
		gun_2 = resource.guns.get(gun_name).instance()
		gun_2.init(name)
		switchToGun(gun_2)


func switchToGun(gun):
	cur_gun = gun
	get_node("CharacterModel").holdWeapon(cur_gun)


func switchGun():
	if gun_1 && gun_2:
		if cur_gun == gun_1:
			switchToGun(gun_2)
		else:
			switchToGun(gun_1)
