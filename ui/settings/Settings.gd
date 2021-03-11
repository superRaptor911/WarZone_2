extends Control

onready var profile_btn = get_node("container/profile")
onready var display_btn = get_node("container/display")
onready var sound_btn = get_node("container/sound") 

# Called when the node enters the scene tree for the first time.
func _ready():
	profile_btn.connect("pressed", self, "_on_profile_pressed")
	display_btn.connect("pressed", self, "_on_display_pressed")
	sound_btn.connect("pressed", self, "_on_sound_pressed") 


func _on_profile_pressed():
	UImanager.changeMenuTo("profile")


func _on_display_pressed():
	UImanager.changeMenuTo("display_settings")


func _on_sound_pressed():
	UImanager.changeMenuTo("sound_settings")
