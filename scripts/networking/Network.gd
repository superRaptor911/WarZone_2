extends Node

var network_registrar = preload("res://scripts/networking/NetworkRegistrar.gd").new()

const Port        = 6969
const Max_Players = 32

# Server only
signal server_creation_failed
signal server_creation_success

# Server and Client
signal client_disconnected(id)
signal client_connected(id)

# Client only
signal connection_success
signal connection_failed
signal disconnected

var player_register = {}

func _ready():
	name = "NetworkManager"
	add_to_group("Network")
	add_child(network_registrar)
	_connectSignals()


func createServer():
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_server(Port, Max_Players) != OK:
		print("Network::Failed to create server")
		emit_signal("server_creation_failed")
		return
	get_tree().network_peer = peer
	player_register[1] = GlobalData.player_info
	var server_advertiser = load("res://scripts/networking/ServerAdvertiser.gd").new()
	add_child(server_advertiser)
	emit_signal("server_creation_success")


func stopServer():
	pass


func connectToServer(ip : String):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, Port)
	get_tree().network_peer = peer


func disconnectFromServer():
	get_tree().network_peer = null


func _connectSignals():
	var tree : SceneTree = get_tree()
	tree.connect("network_peer_connected", self, "_on_peer_connected")
	tree.connect("network_peer_disconnected", self, "_on_peer_disconnected")
	tree.connect("connected_to_server", self, "_on_connected_to_server")
	tree.connect("connection_failed", self, "_on_connection_failed")
	tree.connect("server_disconnected", self, "_on_disconnected")


func _on_peer_disconnected(id):
	print("Network::Client disconnected id=%d" % [id])
	emit_signal("client_disconnected", id)


func _on_peer_connected(id):
	print("Network::Client Connected id=%d" % [id])
	emit_signal("client_connected", id)


func _on_connected_to_server():
	print("Network::Connected to server")
	emit_signal("connection_success")


func _on_connection_failed():
	print("Network::Connection to server failed")
	emit_signal("connection_failed")


func _on_disconnected():
	print("Network::Disconnected from server")
	emit_signal("disconnected")



