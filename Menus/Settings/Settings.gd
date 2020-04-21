extends CanvasLayer


func _ready():
	$Panel/VBoxContainer/music/music.pressed = game_states.game_settings.music_enabled
	$Panel/VBoxContainer/particles/particles.pressed = game_states.game_settings.particle_effects
	$Panel/VBoxContainer/camera/camera.pressed = game_states.game_settings.dynamic_camera

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


func _on_camera_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.dynamic_camera = button_pressed
