extends CanvasLayer


func _ready():
	$TabContainer/Basic/VBoxContainer/music/music.pressed = game_states.game_settings.music_enabled
	$TabContainer/Basic/VBoxContainer/particles/particles.pressed = game_states.game_settings.particle_effects
	$TabContainer/Basic/VBoxContainer/camera/camera.pressed = game_states.game_settings.dynamic_camera
	$TabContainer/Basic/VBoxContainer/shadows/shadows.pressed = game_states.game_settings.shadows
	$TabContainer/Advanced/container/fps/fps.pressed = game_states.game_settings.show_fps
	$TabContainer/Advanced/container/log/log.pressed = game_states.game_settings.enable_logging
	
	$Admob.load_banner()
	UiAnim.animLeftToRight([$TabContainer])

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
	UiAnim.animZoomOut([$TabContainer])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("mainMenu")



func _on_camera_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.dynamic_camera = button_pressed


func _on_shadows_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.shadows = button_pressed


func _on_log_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.enable_logging = button_pressed


func _on_fps_toggled(button_pressed):
	MusicMan.click()
	game_states.game_settings.show_fps = button_pressed
	

func _on_view_logs_pressed():
	MusicMan.click()
	MenuManager.changeScene("set/logViewer")
