extends CanvasLayer

var pause_menu = preload("res://ui/hud/PauseMenu.tscn")

onready var player = get_parent()
onready var hp_label : Label          = get_node("hud/hp")
onready var ammo_label : Label        = get_node("hud/ammo")
onready var pause_btn : TextureButton = get_node("hud/pause_button")


func _ready():
	_connectSignals()


func _connectSignals():
	pause_btn.connect("pressed", self ,"_on_pause_pressed")



func _on_pause_pressed():
	add_child(pause_menu.instance())
