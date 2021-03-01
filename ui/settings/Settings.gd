extends Control

onready var profile_btn = get_node("container/profile")
onready var display_btn = get_node("container/display")

# Called when the node enters the scene tree for the first time.
func _ready():
	profile_btn.connect("pressed", self, "_on_profile_pressed")
	display_btn.connect("pressed", self, "_on_display_pressed")


func _on_profile_pressed():
	UImanager.changeMenuTo("profile")


func _on_display_pressed():
	pass # Replace with function body.
