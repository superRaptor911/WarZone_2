extends Node

var wpn_drop = preload("res://Objects/Misc/WpnDrop.tscn")
var med_drop = preload("res://Objects/Misc/Medkit.tscn")
var kevlar_drop = preload("res://Objects/Misc/Kevlar.tscn")

var droped_item_id = 0
var Items : Dictionary

remotesync func serverMakeItem(item_data):
	droped_item_id += 1
	rpc("createDropedItem",item_data,droped_item_id)

remotesync func createDropedItem(item_data,item_id):
	var drop = null
	
	if item_data.type == "wpn":
		drop = wpn_drop.instance()
	elif item_data.type == "med":
		drop = med_drop.instance()
	elif item_data.type == "kevlar":
		drop = kevlar_drop.instance()
	
	if drop:
		drop.set_name(item_data.type + String(item_id))
		drop.item_id = item_id
		add_child(drop)
		drop.create(item_data)
		if get_tree().is_network_server():
			drop.connect("item_expired",self,"eraseItem")
			Items[item_id] = drop



remotesync func requestPickUp(pid : String,item_id : int):
	var drop = Items.get(item_id)
	if drop:
		var p = null
		var players  = get_tree().get_nodes_in_group("User")
		for i in players:
			if i.name == pid:
				p = i
				break
		p.rpc("pickUpItem",drop.item_data)
		drop.rpc("itemPicked")
		eraseItem(item_id)

func eraseItem(item_id):
	Items.erase(item_id)

