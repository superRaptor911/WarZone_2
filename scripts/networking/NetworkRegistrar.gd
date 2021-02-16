extends Node

onready var network = get_parent()

func _ready():
	name = "NetworkRegistrar"
	if network && !network.is_in_group("Network"):
		print("NetworkRegistrar::Error::parent not Network")
		network = null
	_connectSignals()	


func _connectSignals():
	network.connect("client_connected", self, "_on_client_connected")
	network.connect("client_disconnected", self, "_on_client_disconnected")


func _on_client_connected(id):
	network.player_register[id] = {
			id   = id,
			name = ""
		}


func _on_client_disconnected(id):
	network.player_register.erase(id)

