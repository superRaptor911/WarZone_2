extends CanvasLayer

var pause_menu = preload("res://ui/hud/PauseMenu.tscn")

onready var player = get_parent()
onready var hp_label : Label          = get_node("hud/hp")
onready var ammo_label : Label        = get_node("hud/ammo")
onready var pause_btn : TextureButton = get_node("hud/pause_button")
onready var mov_joy = get_node("mov_joy")
onready var aim_joy = get_node("aim_joy")


func _ready():
	_connectSignals()
	_on_hp_changed()


func _connectSignals():
	pause_btn.connect("pressed", self ,"_on_pause_pressed")
	player.connect("gun_switched", self, "_on_gun_switched")
	player.connect("entity_took_damage", self, "_on_hp_changed")
	# aim_joy.connect("Joystick_Updated", self, "_on_aim_joy_updated")


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


func _on_hp_changed(_attacker = null):
	hp_label.text = String(player.health)


func _process(_delta):
	player.direction = -mov_joy.joystick_vector
	if aim_joy.joystick_vector.length_squared() != 0:
		player.rotation = 1.57 + (-aim_joy.joystick_vector).angle()


func _on_aim_joy_updated(dir : Vector2):
	player.rotation = dir.angle()
	print(dir.angle())

