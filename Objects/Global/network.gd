extends Node2D

var serverAvertiser = null


var players = {}


signal server_created                          # when server is successfully created
signal join_success                            # When the peer successfully joins a server
signal join_fail                               # Failed to join a server
signal player_list_changed                     # List of players has been changed
signal player_removed(pinfo)
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

func _on_player_disconnected(id):
	print("Player ", players[id].name, " disconnected from server")
	if (get_tree().is_network_server()):
		unregister_player(id)
		rpc("unregister_player", id)


func _on_connected_to_server():
	emit_signal("join_success")
	Logger.Log("Connected to server")
	game_states.player_info.net_id = get_tree().get_network_unique_id()
	rpc_id(1, "register_player", game_states.player_info)
	register_player(game_states.player_info)

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
	
func create_server(server_name,port,max_players):
	players.clear()
	var net = NetworkedMultiplayerENet.new()
	Logger.Log("Creating server %s on port %d" % [server_name,port])
	
	if (net.create_server(port,max_players) != OK):
		Logger.Log("Failed to create server on port %d" % [port])	
		return
		
	get_tree().set_network_peer(net)
	emit_signal("server_created")
	Logger.Log("Loading Server Avertiser")
	serverAvertiser = preload("res://Objects/Global/ServerAdvertiser.gd").new()
	register_player(game_states.player_info)
	game_server.serverInfo.port = String(port)
	game_server.serverInfo.max_players = String(max_players)
	game_server.serverInfo.name = server_name
	game_server.serverInfo.plrs = String(players.size())
	
	
func join_server(ip, port):
	Logger.Log("Connecting to server %s:%d" % [ip,port])
	players.clear()
	var net = NetworkedMultiplayerENet.new()
	if (net.create_client(ip, port) != OK):
		emit_signal("join_fail")
		Logger.Log("Connection failed")
		return
	Logger.Log("Connection successful")
	get_tree().set_network_peer(net)


remote func register_player(pinfo):
	if (get_tree().is_network_server()):
		if serverAvertiser:
			serverAvertiser.serverInfo.plrs = String(players.size() + 1)
		for id in players:
			rpc_id(pinfo.net_id, "register_player", players[id])
			if (id != 1):
				rpc_id(id, "register_player", pinfo)

	Logger.Log("Regestering player %s with id %d" % [pinfo.name, pinfo.net_id])
	players[pinfo.net_id] = pinfo          # Create the player entry in the dictionary
	emit_signal("player_list_changed")     # And notify that the player list has been changed


remote func unregister_player(id):
	Logger.Log("Un-regestering player %s with id %d" % [players[id].name, players[id].net_id])
	emit_signal("player_removed", players[id])
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
