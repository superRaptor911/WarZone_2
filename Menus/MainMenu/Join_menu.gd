extends CanvasLayer

var servers = Array()

var serverListener = preload("res://Network/ServerListener.gd").new()

func _ready():
	network.connect("join_fail", self, "_on_join_fail")
	network.connect("join_success", self, "_join_lobby")
	add_child(serverListener)
	serverListener.connect("new_server",self,"on_server_found")



func _on_join_fail():
	print("Failed to join server")
	$pop.show()
	$PanelContainer/Panel/con.hide()

func _join_lobby():
	$con.hide()
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")

func _on_back_button_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")

func on_server_found(server_info):
	$container/port.text = server_info.port
	$container/ip.text = server_info.ip
	if not servers.has(server_info):
		servers.append(server_info)
		print("found")
		updateServerList()
	
	
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
	network.join_server(ip,port)
