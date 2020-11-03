extends Control


func _ready():
	MenuManager.connect("back_pressed", self,"on_back_pressed")
	for i in Logger.logs:
		$Label.text += i + "\n"



func on_back_pressed():
	MenuManager.changeScene("settings")
