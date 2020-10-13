extends CanvasLayer


func _ready():
	UiAnim.animZoomIn([$Panel])
	MenuManager.connect("back_pressed", self,"_on_Button3_pressed")
	MenuManager.admob.show_banner()


func _on_Button_pressed():
	MusicMan.click()
	var _next_scene = "joinMenu"
	MenuManager.changeScene(_next_scene)


func _on_Button2_pressed():
	MusicMan.click()
	var _next_scene = "hostMenu"
	MenuManager.changeScene(_next_scene)


func _on_Button3_pressed():
	MenuManager.changeScene("mainMenu")


func _on_Join_online_pressed():
	MenuManager.changeScene("NG/joinOnline")
