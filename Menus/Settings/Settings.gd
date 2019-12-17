extends CanvasLayer


func _ready():
	pass # Replace with function body.



func _on_Button_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")


func _on_cntrl_pressed():
	get_tree().change_scene("res://Menus/Settings/control_settings.tscn")


func _on_avatar_pressed():
	get_tree().change_scene("res://Menus/Settings/avatar.tscn")