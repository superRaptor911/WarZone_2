extends CanvasLayer


func _ready():
	#$TabContainer/Basic/VBoxContainer/music/music.pressed = game_states.game_settings.music_enabled
	#$TabContainer/Basic/VBoxContainer/particles/particles.pressed = game_states.game_settings.particle_effects
	#$TabContainer/Basic/VBoxContainer/camera/camera.pressed = game_states.game_settings.dynamic_camera
	#$TabContainer/Basic/VBoxContainer/shadows/shadows.pressed = game_states.game_settings.shadows
	#$TabContainer/Advanced/container/fps/fps.pressed = game_states.game_settings.show_fps
	#$TabContainer/Advanced/container/log/log.pressed = game_states.game_settings.enable_logging
	
	#$Admob.load_banner()
	#UiAnim.animLeftToRight([$TabContainer])
	MenuManager.connect("back_pressed", self,"_on_Button_pressed")
	MenuManager.admob.show_interstitial()

func _on_Button_pressed():
	MusicMan.click()
	game_states.saveSettings()
	#UiAnim.animZoomOut([$TabContainer])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeSceneToPrevious()



func _on_display_pressed():
	pass # Replace with function body.


func _on_sound_pressed():
	pass # Replace with function body.


func _on_contols_pressed():
	MenuManager.changeScene("settings/control")
