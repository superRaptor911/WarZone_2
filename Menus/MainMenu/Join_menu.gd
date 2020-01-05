extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("join_fail", self, "_on_join_fail")
	network.connect("join_success", self, "_join_lobby")


func _on_join_fail():
	print("Failed to join server")
	$pop.show()
	$PanelContainer/Panel/con.hide()

func _join_lobby():
	$PanelContainer/Panel/con.hide()
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")

func _on_back_button_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")


func _on_join_button_pressed():
	$PanelContainer/Panel/con.show()
	var port = int( $PanelContainer/Panel/container/port.text)
	var ip = $PanelContainer/Panel/container/ip.text
	network.join_server(ip,port)
