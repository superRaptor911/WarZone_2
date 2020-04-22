extends Node2D

export var spawn_wpn = true
export var weapon_to_spawn = "all"

export var spawn_kits = true
export var kit_to_spawn = "all"

export var spawn_wait = 30

var wpn_drop = preload("res://Objects/Misc/WpnDrop.tscn").instance()
var kits = Array()

func _ready():
	if get_tree().is_network_server():
		spawn_wait = 30
		kits.append("med")
		kits.append("kevlar")
		$Timer.wait_time = spawn_wait
		$Timer.start()


func generateItem():
	if get_tree().is_network_server():
		var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
		if spawn_wpn and spawn_kits:
			var rnd_num = randi() % 2
			if rnd_num == 0:
				d_item_man.rpc_id(1,"serverMakeItem",generateWpn())
			else:
				d_item_man.rpc_id(1,"serverMakeItem",generateKit())
		elif spawn_wpn:
			d_item_man.rpc_id(1,"serverMakeItem",generateWpn())
		else:
			d_item_man.rpc_id(1,"serverMakeItem",generateKit())


func generateKit() -> Dictionary:
	var item_info : Dictionary
	if kit_to_spawn == "all":
		item_info["type"] = kits[randi() % kits.size()]
	else:
		item_info["type"] = kit_to_spawn
	item_info["pos"] = position
	return item_info

func generateWpn() -> Dictionary:
	var wpn
	if weapon_to_spawn == "all":
		var weapons = game_states.weaponResource.values()
		wpn = weapons[randi() % weapons.size()].instance()
	else:
		wpn = game_states.weaponResource.get(weapon_to_spawn).instance()
	wpn.position = position + Vector2(rand_range(-50,50),rand_range(-50,-50))
	
	var rtn_val = wpn_drop.getWpnInfo(wpn)
	wpn.queue_free()
	return rtn_val



func _on_Timer_timeout():
	generateItem()
	$Timer.start()
