extends Control

onready var lang_btn 	= $Panel/scrollPanel/container/lang/Button
onready var shadow_btn 	= $Panel/scrollPanel/container/shadows 
onready var part_btn 	= $Panel/scrollPanel/container/particles
onready var fps_btn 	= $Panel/scrollPanel/container/fps
onready var cam_btn		= $Panel/scrollPanel/container/camera

func _ready():
	part_btn.pressed 	= game_states.game_settings.particle_effects
	cam_btn.pressed 	= game_states.game_settings.dynamic_camera
	shadow_btn.pressed 	= game_states.game_settings.shadows
	fps_btn.pressed		= game_states.game_settings.show_fps
	lang_btn.text		= game_states.game_settings.lang
	
	shadow_btn.connect("toggled", self, "_on_shadows_toggled")
	part_btn.connect("toggled", self, "_on_particles_toggled")
	fps_btn.connect("toggled", self, "_on_fps_toggled")
	cam_btn.connect("toggled", self, "_on_camera_toggled")
	cam_btn.connect("toggled", self, "_on_camera_toggled")
	lang_btn.connect("pressed", self, "_on_lang_btn_pressed")
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func _on_shadows_toggled(button_pressed):
	game_states.game_settings.shadows = button_pressed


func _on_particles_toggled(button_pressed):
	game_states.game_settings.particle_effects = button_pressed


func _on_fps_toggled(button_pressed):
	game_states.game_settings.show_fps = button_pressed


func _on_camera_toggled(button_pressed):
	game_states.game_settings.dynamic_camera = button_pressed


func _on_lang_btn_pressed():
	pass


func _on_back_pressed():
	game_states.saveSettings()
	MenuManager.changeSceneToPrevious()
