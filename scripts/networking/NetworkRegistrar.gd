extends Node

onready var network = get_parent()

func _ready():
	name = "NetworkRegistrar"
	_connectSignals()	


func _connectSignals():
	network.connect("client_connected", self, "_on_client_connected")
	network.connect("client_disconnected", self, "_on_client_disconnected")
	network.connect("connection_success", self, "_on_connected_to_server")


func _on_client_connected(id):
	network.player_register[id] = {}
	# Update player count in serverAdvertiser
	if get_tree().is_network_server():
		var server_advertiser = network.get_node("ServerAdvertiser")
		server_advertiser.serverInfo.players = network.player_register.size()


func _on_client_disconnected(id):
	network.player_register.erase(id)


func _on_connected_to_server():
	var id = get_tree().get_network_unique_id()
	network.player_register[id] = GlobalData.player_info
	rpc("C_syncPlayerInfo", id, GlobalData.player_info)
	rpc_id(1, "S_getRegistry", id)



# Networking

remote func C_syncPlayerInfo(id : int, player_info : Dictionary):
	network.player_register[id] = player_info


remote func S_getRegistry(peer_id : int):
	rpc_id(peer_id, "C_getRegistry", network.player_register)


remote func C_getRegistry(data : Dictionary):
	network.player_register = data

