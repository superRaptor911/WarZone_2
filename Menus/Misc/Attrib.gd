extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	UiAnim.animRightToLeft([$Panel])
	UiAnim.animTopToBottom([$TextureRect/Label])
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func _on_Label_meta_clicked(meta):
	OS.shell_open("https://"+ meta)


func _on_back_pressed():
	MenuManager.changeSceneToPrevious()
