extends Node

const listenPort = 8086
var cleanUpTimer = Timer.new()
var socketUDP    = PacketPeerUDP.new()
var knownServers = {}

signal new_server(serverInfo)
signal remove_server(ip)

const CLEANUP_THRESHOLD = 3

func _init():
	cleanUpTimer.wait_time = CLEANUP_THRESHOLD
	cleanUpTimer.one_shot = false
	cleanUpTimer.autostart = true
	cleanUpTimer.connect("timeout", self, 'clean_up')
	add_child(cleanUpTimer)


func _ready():
	name = "ServerListener"
	knownServers.clear()
	if socketUDP.listen(listenPort,"255.255.255.255") != OK:
		print("ServerListener::Error listening on port: " + str(listenPort))
	else:
		print("ServerListener::Listening on port: " + str(listenPort))


func _process(_delta):
	if socketUDP.get_available_packet_count() > 0:
		var serverIp = socketUDP.get_packet_ip()
		var serverPort = socketUDP.get_packet_port()
		var array_bytes = socketUDP.get_packet()
		
		if serverIp != '' && serverPort > 0:
			# We've discovered a new server! Add it to the list and let people know
			if !knownServers.has(serverIp):
				var serverMessage = array_bytes.get_string_from_ascii()
				var gameInfo = parse_json(serverMessage)
				if gameInfo:
					gameInfo.ip = serverIp
					gameInfo.lastSeen = OS.get_unix_time()
					knownServers[serverIp] = gameInfo
					print("ServerListener::New server found: %s - %s" % [gameInfo.name, gameInfo.ip ])
					emit_signal("new_server", gameInfo)
			# Update the last seen time
			else:
				var gameInfo = knownServers[serverIp]
				gameInfo.lastSeen = OS.get_unix_time()


func clean_up():
	var now = OS.get_unix_time()
	for serverIp in knownServers:
		var serverInfo = knownServers[serverIp]
		if (now - serverInfo.lastSeen) > CLEANUP_THRESHOLD:
			knownServers.erase(serverIp)
			print('ServerListener::Remove old server: %s' % serverIp)
			emit_signal("remove_server", serverIp)


func _exit_tree():
	socketUDP.close()
