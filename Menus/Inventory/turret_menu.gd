extends CanvasLayer

#move to inventory menu
func _on_quit_pressed():
	get_tree().root.add_child(load("res://Menus/Inventory/inventory_menu.tscn").instance())
	queue_free()




func _on_AKTurret_close_this():
	queue_free()
