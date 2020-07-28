extends CanvasLayer

var next_scene : String

onready var admob = $AdMob

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created",self,"_join_lobby")
	UiAnim.animTopToBottom([$panel])
	MenuManager.connect("back_pressed", self,"_on_back_pressed")
	admob.load_banner()

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

func _exit_tree():
	admob.hide_banner()
