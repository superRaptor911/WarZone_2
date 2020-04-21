extends CanvasLayer


func _ready():
	$Panel/VBoxContainer/music/music.pressed = game_states.game_settings.music_enabled
	$Panel/VBoxContainer/particles/particles.pressed = game_states.game_settings.particle_effects

func _on_music_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.music_enabled = button_pressed
	if button_pressed:
		MusicMan.playMusic()
	else:
		MusicMan.stopMusic()


func _on_particles_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.particle_effects = button_pressed
	


func _on_Button_pressed():
	MusicMan.click()
	game_states.saveSettings()
	MenuManager.changeScene("mainMenu")
