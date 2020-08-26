extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	MenuManager.connect("back_pressed" , self , "on_back_pressed")




func _on_maps_pressed():
	MenuManager.changeScene("CM/ComMapMenu")


func _on_chat_pressed():
	pass # Replace with function body.

func on_back_pressed():
	MenuManager.changeScene("mainMenu")
