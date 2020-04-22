extends CanvasLayer

var next_scene : String


# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created",self,"_join_lobby")
	startingTween()
	$Admob.load_banner()

func _join_lobby():
	MenuManager.changeScene("HM/lobby")

func _on_create_pressed():
	var port = int($panel/contatiner/e3.text)
	var max_p = int($panel/contatiner/e2.text)
	var sever_name = $panel/contatiner/e1.text
	MusicMan.click()
	network.create_server(sever_name,port,max_p)

func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("mainMenu")

######################Tween ###################################################

onready var panel_ipos = $panel.rect_position

func startingTween():
	var duration = 0.5
	$panel.rect_pivot_offset = $panel.rect_size / 2
	$panel.rect_scale = Vector2(0.01,0.01)
	$Tween.interpolate_property($panel,"rect_scale",$panel.rect_scale,Vector2(1,1),
		duration,Tween.TRANS_QUAD,Tween.EASE_OUT,0.1)
	$Tween.start()
