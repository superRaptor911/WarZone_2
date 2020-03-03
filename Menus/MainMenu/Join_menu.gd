extends CanvasLayer

var servers = Array()
var serverListener = preload("res://Network/ServerListener.gd").new()
var current_server
var serverInfoFormatStr = "Server Name : %s\nGame Mode : %s\nMap : %s"

func _ready():
	network.connect("join_fail", self, "_on_join_fail")
	network.connect("join_success", self, "_join_game")
	add_child(serverListener)
	serverListener.connect("new_server",self,"on_server_found")
	serverListener.connect("remove_server", self, "on_server_closed")



func _on_join_fail():
	print("Failed to join server")
	$pop.show()
	$PanelContainer/Panel/con.hide()

func _join_game():
	$con.hide()
	var level_path = "res://Maps/" + current_server.map + "/" + current_server.map + ".tscn"
	get_tree().change_scene(level_path)

func _on_back_button_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")

func on_server_found(server_info):
	current_server = server_info
	$container/port.text = server_info.port
	$container/ip.text = server_info.ip
	updateServerInfo()
	if not servers.has(server_info):
		servers.append(server_info)
		print("found")
		updateServerList()

func on_server_closed(ip):
	var old_server = null
	for i in servers:
		if i.ip == ip:
			servers.erase(i)
			print("removing ",ip)
			updateServerList()
			break

func updateServerList():
	var slots = $serverList/serverList.get_children()
	var index = 0
	for i in slots:
		if index < servers.size():
			i.show()
			i.get_node("label").text = servers[index].name
		else:
			i.hide()
		index += 1
	

func _on_join_button_pressed():
	$con.show()
	var port = int( $container/port.text)
	var ip = $container/ip.text
	game_server.serverInfo = current_server
	network.join_server(ip,port)


func _on_b1_pressed():
	current_server = servers[0]
	var svr = servers[0]
	$container/port.text = svr.port
	$container/ip.text = svr.ip

func _on_b2_pressed():
	current_server = servers[1]
	var svr = servers[1]
	$container/port.text = svr.port
	$container/ip.text = svr.ip
	
func _on_b3_pressed():
	current_server = servers[2]
	var svr = servers[2]
	$container/port.text = svr.port
	$container/ip.text = svr.ip

func _on_b4_pressed():
	current_server = servers[3]
	var svr = servers[3]
	$container/port.text = svr.port
	$container/ip.text = svr.ip

func _on_b5_pressed():
	current_server = servers[4]
	var svr = servers[4]
	$container/port.text = svr.port
	$container/ip.text = svr.ip

func updateServerInfo():
	var serverInfoStr = serverInfoFormatStr % [current_server.name,current_server.game_mode,
											current_server.map]
	$PanelContainer/serverInfo/Label.text = serverInfoStr
