extends CanvasLayer


func _ready():
	UiAnim.animZoomIn([$Panel])
	MenuManager.connect("back_pressed", self,"_on_Button3_pressed")


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

