extends Node
class_name ServerAdvertiser

const DEFAULT_PORT := 3111

export (float) var broadcast_interval: float = 1.0

var serverInfo := {
	"name": "Raptors LAN Game",
	"ip" : "127.0.0.1",
	"port" : "6969",
	"game_mode" : "FFA",
	"max_p" : "6",
	"plrs" : "0",
	"map" : "",
}

var socketUDP: PacketPeerUDP
var broadcastTimer := Timer.new()
var broadcastPort := DEFAULT_PORT

func _enter_tree():
	broadcastTimer.wait_time = broadcast_interval
	broadcastTimer.one_shot = false
	broadcastTimer.autostart = true
	
	if get_tree().is_network_server():
		add_child(broadcastTimer)
		broadcastTimer.connect("timeout", self, "broadcast") 
		
		socketUDP = PacketPeerUDP.new()
		socketUDP.set_broadcast_enabled(true)
		socketUDP.set_dest_address("255.255.255.255", broadcastPort)

func broadcast():
	#print('Broadcasting game...')
	var packetMessage := to_json(serverInfo)
	var packet := packetMessage.to_ascii()
	socketUDP.put_packet(packet)

func _exit_tree():
	broadcastTimer.stop()
	if socketUDP != null:
		socketUDP.close()
