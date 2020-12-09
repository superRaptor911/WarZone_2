#Unit is a character that can use weapons.
#Units can drop/pick weapons
#group : Unit
class_name Unit
extends "res://Objects/Character.gd"

#attributes
var pname	 				= ""
var kills					= 0
var deaths					= 0
var score		 			= 0
var ping					= 0
var last_attacker_id 		= ""
var last_fired_timestamp 	= 0
var prim_gun		 		= ""
var sec_gun 				= ""
var cash					= 1000
var spotted_by_enimies 		= false



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
	var g = null
	var g2 = game_states.weaponResource[nam2].instance()

	if game_states.weaponResource.has(nam):
		g = game_states.weaponResource[nam].instance()	
		
	selected_gun = null
	unselected_gun = null	
	if gun_1:
		gun_1.queue_free()
	if gun_2:
		gun_2.queue_free()
	if g:
		gun_1 = g
		gun_1.name = nam
		gun_1.user_id = name
		selected_gun = gun_1
		unselected_gun = g2

	gun_2 = g2
	gun_2.name = nam2
	gun_2.user_id = name		
	if not selected_gun:
		selected_gun = gun_2
	
	setSelectedGun()
	prim_gun = nam
	sec_gun = nam2
	emit_signal("gun_loaded")


remotesync func P_loadGuns(g1, g2):
	loadGuns(g1, g2)

#show selected gun
func setSelectedGun():
	model.switchGun(selected_gun)
	selected_gun.user_id = name
	selected_gun.position = Vector2.ZERO
	if not selected_gun.is_connected("gun_fired", self, "on_gun_fired"):
		selected_gun.connect("gun_fired", self, "on_gun_fired")

#switch gun
remotesync func switchGun():
	if unselected_gun:
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
	position = level.getSpawnPosition(team.team_id)
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
	loadGuns("", "Glock")
	model.revive()
	$dtween.stop_all()
	model.modulate = Color8(255,255,255,255)
	if not was_alive:
		emit_signal("char_born")
	emit_signal("respawned")


#Creates weapon drop, when killed
func createDropedItems():
	var d_item_man = level.dropedItem_manager
	#drop selected gun
	d_item_man.rpc_id(1,"serverMakeItem",wpn_drop.getWpnInfo(selected_gun))
	
	#drop health pack (5 % chance)
	if randi() % 100 <= 5: 
		var item_info = {type = "med",pos = position}
		d_item_man.rpc_id(1,"serverMakeItem",item_info)
	# drop kevlar (20 % chance)
	if randi() % 100 <= 10: 
		var item_info = {type = "kevlar",pos = position}
		d_item_man.rpc_id(1,"serverMakeItem",item_info)
	# drop ammo (5 % chance)
	if randi() % 100 <= 5: 
		var item_info = {type = "ammo",pos = position}
		d_item_man.rpc_id(1,"serverMakeItem",item_info)


#function is called when unit is killed, this is used
#to drop weapons on ground.
func P_on_unit_killed():
	createDropedItems()

func _on_respawn_timer_timeout():
	if get_tree().is_network_server():
		S_respawnUnit()

# Freeze player
func S_freezeUnit(val = true):
	rpc("P_freezeUnit", val)

remotesync func P_freezeUnit(val):
	paused = val


func on_gun_fired():
	last_fired_timestamp = OS.get_ticks_msec() / 1000
