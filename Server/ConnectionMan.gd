#	Connection Manager
#	Program to connect to a server.
extends Control

# Label
onready var status_label = $status

# Server Listener, for Local search
var serverListener = preload("res://Objects/Global/ServerListener.gd").new()
# list of servers
var servers = Array()



# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals
	network.connect("join_fail", self, "_on_join_fail")
	network.connect("join_success", self, "_join_game")
	# Add listener
	add_child(serverListener)
	# Connect signals
	serverListener.connect("new_server",self,"on_server_found")
	serverListener.connect("remove_server", self, "on_server_closed")


# Called when a server is discovered
func on_server_found(server_info):
	echo("Found new server \"%s\" [IP : %s]" % [server_info.name, server_info.ip])
	if not servers.has(server_info):
		servers.append(server_info)
		updateServerList()


# Update list of servers in server list
func updateServerList():
	$server_list.clear()
	for i in servers:
		$server_list.add_item(i.name)


# Called when a server is closed
func on_server_closed(ip):
	echo("A server was closed")
	for i in servers:
		if i.ip == ip:
			servers.erase(i)
			echo("removing server \"%s\" [IP %s]" % [i.name, ip])
			updateServerList()
			return
	echo("Error : Unable to find server with IP : %s" % [ip])


# Function to print messages
func echo(msg : String):
	print(msg)
	status_label.text += '\n' + msg


func _on_connect_pressed():
	if servers.empty():
		print("No server found")
		return
	
	var cur_server = servers[$server_list.get_selected_id()]
	game_server.serverInfo = cur_server
	network.join_server(cur_server.ip, int(cur_server.port))
	network.connect("join_success", self, "on_connected")



func on_connected():
	game_states.is_sysAdmin = true
	network.rpc_id(1, "S_register_sysAdmin", game_states.player_info.net_id)
	get_tree().change_scene("res://Server/serverStatus.tscn")
