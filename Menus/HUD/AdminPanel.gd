extends Panel



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	queue_free()
