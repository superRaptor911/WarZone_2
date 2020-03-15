extends CanvasLayer

func _ready():
	$PanelContainer/Panel/particles.pressed = game_states.game_settings.particle_effects
	$PanelContainer/Panel/lights.pressed = game_states.game_settings.lighting_effects
	$PanelContainer/Panel/laser.pressed = game_states.game_settings.laser_targeting

func _on_particles_toggled(button_pressed):
	game_states.game_settings.particle_effects = button_pressed


func _on_back_pressed():
	game_states.saveSettings()
	get_tree().change_scene("res://Menus/Settings/Settings.tscn")


func _on_lights_toggled(button_pressed):
	game_states.game_settings.lighting_effects = button_pressed


func _on_laser_toggled(button_pressed):
	game_states.game_settings.laser_targeting = button_pressed
