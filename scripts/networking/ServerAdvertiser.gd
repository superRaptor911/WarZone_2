extends Node
class_name ServerAdvertiser

const DEFAULT_PORT = 8086

var broadcast_interval : float = 1.5
var serverInfo = {
	name      = "Warzone 2 Lan Game",
	map       = "",
	game_mode = "",
	players   = 0
}

var socketUDP: PacketPeerUDP
var broadcastTimer := Timer.new()
var broadcastPort := DEFAULT_PORT


func _ready():
	name = "ServerAdvertiser"
	broadcastTimer.wait_time = broadcast_interval
	broadcastTimer.one_shot  = false
	broadcastTimer.autostart = true
	if get_tree().is_network_server():
		add_child(broadcastTimer)
		broadcastTimer.connect("timeout", self, "broadcast") 
		socketUDP = PacketPeerUDP.new()
		socketUDP.set_broadcast_enabled(true)
		socketUDP.set_dest_address("255.255.255.255", broadcastPort)
		print("ServerAdvertiser::Loaded server_advertiser")


func broadcast():
	var packetMessage := to_json(serverInfo)
	var packet := packetMessage.to_ascii()
	socketUDP.put_packet(packet)


func _exit_tree():
	broadcastTimer.stop()
	if socketUDP != null:
		socketUDP.close()
