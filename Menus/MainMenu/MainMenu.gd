extends CanvasLayer


func _ready():
	get_tree().paused = false

var _next_scene : String  


func _on_Button_pressed():
	$btn_click.play()
	_next_scene = "res://Menus/MainMenu/Join_menu.tscn"


func _on_Button2_pressed():
	$btn_click.play()
	_next_scene = "res://Menus/MainMenu/host_menu.tscn"


func _on_Button3_pressed():
	$btn_click.play()
	_next_scene = "res://Menus/Settings/Settings.tscn"






func _on_btn_click_finished():
	get_tree().change_scene(_next_scene);
