extends CanvasLayer

var next_scene : String
var btn_click

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created",self,"_join_lobby")
	btn_click = get_tree().root.get_node("btn_click")
	startingTween()

func _join_lobby():
	get_tree().change_scene("res://Menus/Lobby/Lobby.tscn")


func _on_create_pressed():
	var port = int($panel/contatiner/e3.text)
	var max_p = int($panel/contatiner/e2.text)
	var sever_name = $panel/contatiner/e1.text
	btn_click.play()
	network.create_server(sever_name,port,max_p)

func _on_back_pressed():
	btn_click.play()
	next_scene = "res://Menus/MainMenu/MainMenu.tscn"
	get_tree().change_scene(next_scene);

######################Tween ###################################################

onready var panel_ipos = $panel.rect_position

func startingTween():
	var duration = 0.5
	$panel.rect_pivot_offset = $panel.rect_size / 2
	$panel.rect_scale = Vector2(0.01,0.01)
	$Tween.interpolate_property($panel,"rect_scale",$panel.rect_scale,Vector2(1,1),
		duration,Tween.TRANS_QUAD,Tween.EASE_OUT,0.1)
	$Tween.start()
