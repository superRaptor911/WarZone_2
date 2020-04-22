extends CanvasLayer


func _ready():
	$Admob.load_banner()

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
