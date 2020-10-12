extends Control


func _on_gui_status_pressed():
	get_tree().change_scene("res://Server/serverStatus.tscn")



func _on_console_pressed():
	get_tree().change_scene("res://Server/AdminConsole.tscn")
