extends Control

func _ready():
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_TDM_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LEM/GMM/TDM")


func _on_ZOMBIE_pressed():
	pass # Replace with function body.


func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LevelEditorMenu")
