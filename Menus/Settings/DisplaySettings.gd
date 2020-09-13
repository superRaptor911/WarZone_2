extends Control


func _ready():
	$Panel/VBoxContainer/particles.pressed = game_states.game_settings.particle_effects
	$Panel/VBoxContainer/camera.pressed = game_states.game_settings.dynamic_camera
	$Panel/VBoxContainer/shadows.pressed = game_states.game_settings.shadows
	$Panel/VBoxContainer/fps.pressed = game_states.game_settings.show_fps
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_shadows_toggled(button_pressed):
	game_states.game_settings.shadows = button_pressed


func _on_particles_toggled(button_pressed):
	game_states.game_settings.particle_effects = button_pressed


func _on_fps_toggled(button_pressed):
	game_states.game_settings.show_fps = button_pressed


func _on_camera_toggled(button_pressed):
	game_states.game_settings.dynamic_camera = button_pressed


func _on_back_pressed():
	game_states.saveSettings()
	MenuManager.changeSceneToPrevious()
