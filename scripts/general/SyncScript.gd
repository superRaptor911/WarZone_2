extends Node

var spawn_manager = null


func _ready():
	name = "SyncScript"

func syncAll(sm):
	spawn_manager = sm
	syncPlayers()


func syncPlayers():
	print("SyncScript::Syncing players from the server")
	rpc_id(1, "S_syncPlayers", get_tree().get_network_unique_id())


remote func S_syncPlayers(peer_id : int):
	var list = []
	var units = get_tree().get_nodes_in_group("Players")
	for i in units:
		list.append({
				name    = i.name,
				team_id = i.team_id,
				hp      = i.health,
				ap      = i.armour,
				pos		= i.position,
				rot		= i.rotation,
				gun1    = "",
				gun2    = "",
				cur_gun = "",
			})

	rpc_id(peer_id, "C_syncPlayers", list)


remote func C_syncPlayers(list : Array):
	print("SyncScript::Got %d players to spawn" % [list.size()])
	for i in list:
		spawn_manager.createPlayer(int(i.name), i.team_id)
