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
	player.connect("gun_switched", self, "_on_gun_switched")


func _on_pause_pressed():
	add_child(pause_menu.instance())

func _on_gun_switched():
	if !player.cur_gun.is_connected("gun_fired", self, "_on_gun_gired"):
		player.cur_gun.connect("gun_fired", self, "_on_gun_gired")
	fillAmmoInfo(player.cur_gun)


func _on_gun_gired():
	fillAmmoInfo(player.cur_gun)


func fillAmmoInfo(wpn):
	var format = "%d / %d"
	ammo_label.text = format % [wpn.bullets_in_mag, wpn.bullets]

