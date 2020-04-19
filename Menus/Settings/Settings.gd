extends CanvasLayer


func _ready():
	pass # Replace with function body.


func _on_music_toggled(button_pressed):
	game_states.game_settings.particle_effects = button_pressed


func _on_particles_toggled(button_pressed):
	game_states.game_settings.music_enabled = button_pressed


func _on_Button_pressed():
	game_states.saveSettings()
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")
