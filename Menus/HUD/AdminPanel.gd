extends Panel

signal adminPanel_closed


func _on_PlrList_pressed():
	MusicMan.click()
	var admin_menu = load("res://Menus/HUD/admin_menu.tscn").instance()
	add_child(admin_menu)


func _on_bot_pressed():
	MusicMan.click()
	var menu = load("res://Menus/HUD/botMenul.tscn").instance()
	add_child(menu)


func _on_quit_pressed():
	MusicMan.click()
	emit_signal("adminPanel_closed")
