extends TextureButton
signal close_this


func _on_AKTurret_pressed():
	var turret = load("res://Objects/Weapons/light_turret.tscn").instance()
	turret.gun_name = "AK47"
	turret.setup_main_gun()
	var turret_build_menu = load("res://Menus/Inventory/turret_option.tscn").instance()
	turret_build_menu.turret = turret
	get_tree().root.add_child(turret_build_menu)
	emit_signal("close_this")
