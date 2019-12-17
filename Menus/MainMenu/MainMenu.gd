extends CanvasLayer


func _ready():
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Menus/MainMenu/Join_menu.tscn")


func _on_Button2_pressed():
	get_tree().change_scene("res://Menus/MainMenu/host_menu.tscn")


func _on_Button3_pressed():
	get_tree().change_scene("res://Menus/Settings/Settings.tscn")


