extends Control

func _ready():
	MenuManager.connect("back_pressed", self,"_on_back_pressed")
	MenuManager.admob.show_banner()

func _on_TDM_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LEM/GMM/TDM")


func _on_ZOMBIE_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LEM/GMM/ZM")


func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LevelEditorMenu")
