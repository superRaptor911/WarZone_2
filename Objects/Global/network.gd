# Network
extends Node2D

# Server advertiser for lan
var serverAvertiser = null
# List of connected players
var players = {}

var sysAdmin_online = false
var sysAdmin_id = ""

# Signals
signal server_created                          # when server is successfully created
signal join_success                            # When the peer successfully joins a server
signal join_fail                               # Failed to join a server
signal player_list_changed                     # List of players has been changed
signal player_removed(pinfo)				   # Called when player is removed
signal disconnected
signal server_stopped



func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")


func _on_player_connected(_id):
	pass

# Called when player disconnects
func _on_player_disconnected(id):
	print("Player ", players[id].name, " disconnected from server")
	if get_tree().is_network_server():
		rpc("unregister_player", id)


# Called when connected to server
func _on_connected_to_server():
	emit_signal("join_success")
	Logger.Log("Connected to server")
	game_states.player_info.net_id = get_tree().get_network_unique_id()
	rpc("register_player", game_states.player_info)


func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)


func _on_disconnected_from_server():
	print("Disconnected from server")
	# Clear the network object
	get_tree().set_network_peer(null)
	# Allow outside code to know about the disconnection
	emit_signal("disconnected")
	# Clear the internal player list
	players.clear()
	# Reset the player info network ID
	game_states.player_info.net_id = 1


# Create server
func create_server(server_name, port, max_players):
	players.clear()
	var net = NetworkedMultiplayerENet.new()
	Logger.Log("Creating server %s on port %d" % [server_name,port])
	
	if net.create_server(port,max_players) != OK:
		Logger.Log("Failed to create server on port %d" % [port])	
		return
		
	get_tree().set_network_peer(net)
	emit_signal("server_created")
	Logger.Log("Loading Server Avertiser")
	serverAvertiser = preload("res://Objects/Global/ServerAdvertiser.gd").new()
	# Register self
	rpc("register_player", game_states.player_info)
	# Set server info
	game_server.serverInfo.port = String(port)
	game_server.serverInfo.max_players = String(max_players)
	game_server.serverInfo.name = server_name
	game_server.serverInfo.plrs = String(1)
	

# Join server
func join_server(ip, port):
	Logger.Log("Connecting to server %s:%d" % [ip,port])
	players.clear()
	var net = NetworkedMultiplayerENet.new()
	if net.create_client(ip, port) != OK:
		Logger.Log("Failed to connect to %s:%s" % [ip, port])
		emit_signal("join_fail")
		return
	Logger.Log("Connection successful")
	Logger.Log("Connected to %s:%s" % [ip, port])
	get_tree().set_network_peer(net)


# Register Player
remotesync func register_player(pinfo):
	# Server side
	if get_tree().is_network_server():
		if serverAvertiser:
			serverAvertiser.serverInfo.plrs = String(players.size() + 1)

	Logger.Log("Regestering player %s with id %d" % [pinfo.name, pinfo.net_id])
	players[pinfo.net_id] = pinfo          # Create the player entry in the dictionary
	emit_signal("player_list_changed")     # And notify that the player list has been changed


remotesync func unregister_player(id):
	Logger.Log("Un-regestering player %s with id %d" % [players[id].name, players[id].net_id])
	emit_signal("player_removed", players[id])
	
	if sysAdmin_online and sysAdmin_id == id:
		sysAdmin_online = false
		sysAdmin_id = ""
		Logger.Log("SysAdmin Left")
	
	players.erase(id)
	emit_signal("player_list_changed")
	

remote func kick_player(net_id, reason):
	if get_tree().is_network_server():
		if net_id == 1:
			Logger.Log("Kicking server player, Server will be closed")
			_close_server()
		else:
			Logger.Log("Kicking player %d for %s" % [net_id,reason])
			rpc_id(net_id,"kicked", reason)
			get_tree().network_peer.disconnect_peer(net_id)


remote func kicked(reason):
	#get_tree().network_peer.disconnect_peer(game_states.player_info.net_id)
	#get_tree().network_peer.disconnect_peer(game_states.player_info.net_id)
	print("You have been kicked from the server, reason: ", reason)


func _close_server():
	#kick players
	for i in players:
		if i != 1:
			print(i)
			rpc_id(i,"kicked", "Server Closed")
			get_tree().network_peer.disconnect_peer(i)
	players.clear()
	#Terminate server
	get_tree().set_network_peer(null)
	emit_signal("server_stopped")
	serverAvertiser.queue_free()
	serverAvertiser = null
	get_tree().get_nodes_in_group("Level")[0].queue_free()
	MenuManager.changeScene("summary")
	

func stopServer():
	Logger.Log("Closing server")
	#kick players
	for i in players:
		if i != 1:
			print(i)
			rpc_id(i,"kicked", "Server Closed")
			get_tree().network_peer.disconnect_peer(i)
	players.clear()
	#Terminate server
	get_tree().set_network_peer(null)
	emit_signal("server_stopped")
	serverAvertiser.queue_free()


remote func S_register_sysAdmin(admin_id : String):
	if get_tree().is_network_server():
		sysAdmin_online = true
		sysAdmin_id = admin_id
	else:
		Logger.Log("Error: Unable to register sysAdmin, This is not server")
