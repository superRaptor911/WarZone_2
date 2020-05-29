#Unit is a character that can use weapons.
#Units can drop/pick weapons
#group : Unit
class_name Unit
extends "res://Objects/Character.gd"

export var regen_rate : float = 5

#attributes
var pname : String = ""
var kills : int = 0
var deaths : int = 0
var score : int = 0
var ping : int = 0
var last_attacker_id : String = ""
var prim_gun = ""
var sec_gun = ""

#weapons
var gun_1 : Gun = null
var gun_2 : Gun = null
var selected_gun : Gun = null
var unselected_gun : Gun = null

#weapon drop, used to drop weapons
var wpn_drop = preload("res://Objects/Misc/WpnDrop.tscn").instance()

signal gun_switched
signal respawned
signal gun_loaded


func _ready():
	if is_network_master():
		connect("char_killed",self,"P_on_unit_killed")


#load new guns
func loadGuns(nam : String , nam2 : String):
	model.resetGunSelection()
	var g = game_states.weaponResource[nam].instance()
	var g2 = game_states.weaponResource[nam2].instance()
	selected_gun = null
	unselected_gun = null
	
	if gun_1:
		gun_1.queue_free()
	if gun_2:
		gun_2.queue_free()
	
	gun_1 = g
	gun_2 = g2
	gun_1.name = nam
	gun_2.name = nam2
	gun_1.user_id = name
	gun_2.user_id = name

	selected_gun = gun_1
	unselected_gun = gun_2
	setSelectedGun()
	emit_signal("gun_loaded")


#show selected gun
func setSelectedGun():
	model.switchGun(selected_gun)
	selected_gun.user_id = name
	selected_gun.position = Vector2.ZERO

#switch gun
remotesync func switchGun():
	var temp = selected_gun
	selected_gun = unselected_gun
	unselected_gun = temp
	setSelectedGun()
	emit_signal("gun_switched")


func switchToPrimaryGun():
	if selected_gun != gun_1:
		rpc("switchGun")

func switchToSecondaryGun():
	if selected_gun != gun_2:
		rpc("switchGun")

#respawn player, server only
func S_respawnUnit():
	position = get_tree().get_nodes_in_group("Level")[0].getSpawnPosition(team.team_id)
	rpc("P_respawnUnit",position)

#respawn unit to a new position
remotesync func P_respawnUnit(pos):
	var was_alive = alive
	show()
	alive = true
	HP = 100
	AP = 100
	model.set_deferred("disabled",false)
	$movmtCPP._teleportCharacter(pos)
	loadGuns(prim_gun, sec_gun)
	model.revive()
	$dtween.stop_all()
	model.modulate = Color8(255,255,255,255)
	if not was_alive:
		emit_signal("char_born")
	emit_signal("respawned")


#Creates weapon drop, when killed
func createDropedItems():
	var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
	#drop selected gun
	d_item_man.rpc_id(1,"serverMakeItem",wpn_drop.getWpnInfo(selected_gun))
	
	#drop health pack (10 % chance)
	if randi() % 100 <= 10: 
		var item_info = {type = "med",pos = position}
		d_item_man.rpc_id(1,"serverMakeItem",item_info)
	
	#drop kevlar (20 % chance)
	if randi() % 100 <= 20: 
		var item_info = {type = "kevlar",pos = position}
		d_item_man.rpc_id(1,"serverMakeItem",item_info)

#function is called when unit is killed, this is used
#to drop weapons on ground.
func P_on_unit_killed():
	createDropedItems()
