extends CanvasLayer

var next_scene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created",self,"_join_lobby")

func _join_lobby():
	next_scene = "res://Menus/Lobby/GameModes.tscn"


func _on_create_pressed():
	var port = int($panel/contatiner/e3.text)
	var max_p = int($panel/contatiner/e2.text)
	var sever_name = $panel/contatiner/e1.text
	$btn_click.play()
	network.create_server(sever_name,port,max_p)
	


func _on_back_pressed():
	$btn_click.play()
	next_scene = "res://Menus/MainMenu/MainMenu.tscn"


func _on_btn_click_finished():
	get_tree().change_scene(next_scene);
