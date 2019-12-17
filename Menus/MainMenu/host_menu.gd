extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created",self,"_join_lobby")

func _join_lobby():
	print("ds")
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")


func _on_create_pressed():
	var port = int($PanelContainer/Panel/port.text)
	var max_p = int($PanelContainer/Panel/max_pl.text)
	network.create_server(port,max_p)


func _on_back_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")
