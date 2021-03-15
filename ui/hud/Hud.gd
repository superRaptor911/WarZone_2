extends CanvasLayer

var pause_menu = preload("res://ui/hud/PauseMenu.tscn")
var buy_menu = preload("res://ui/buyMenu/BuyMenu.tscn")

onready var player              = get_parent()
onready var hp_label            = get_node("hud/hp")
onready var ap_label			= get_node("hud/ap") 
onready var ammo_label          = get_node("hud/ammo")
onready var pause_btn           = get_node("hud/pause_button")
onready var buy_btn             = get_node("hud/buy_btn")
onready var mov_joy             = get_node("hud/mov_joy")
onready var aim_joy             = get_node("hud/aim_joy")
onready var zoom_btn            = get_node("hud/zoom_btn")
onready var next_gun_btn        = get_node("hud/next_gun")
onready var reload_gun_btn      = get_node("hud/reload_gun")
onready var reload_progress_bar = get_node("hud/reloading_bar")
onready var tween               = get_node("Tween")


func _ready():
	name = "Hud"
	_connectSignals()
	_on_hp_changed()


func _connectSignals():
	pause_btn.connect("pressed", self ,"_on_pause_pressed")
	buy_btn.connect("pressed", self ,"_on_buy_pressed")
	zoom_btn.connect("pressed", self, "_on_zoom_pressed") 
	next_gun_btn.connect("pressed", self, "_on_next_gun_pressed") 
	reload_gun_btn.connect("pressed", self, "_on_reload_pressed") 
	player.connect("gun_switched", self, "_on_gun_switched")
	player.connect("entity_took_damage", self, "_on_hp_changed")
	player.connect("entity_revived", self, "_on_hp_changed") 


func _on_buy_pressed():
	add_child(buy_menu.instance())


func _on_pause_pressed():
	add_child(pause_menu.instance())


func _on_gun_switched():
	if !player.cur_gun.is_connected("gun_fired", self, "_on_gun_fired"):
		player.cur_gun.connect("gun_fired", self, "_on_gun_fired")
	if !player.cur_gun.is_connected("gun_reloaded", self, "_on_gun_reloaded"):
		player.cur_gun.connect("gun_reloaded", self, "_on_gun_reloaded")
	fillAmmoInfo(player.cur_gun)
	player.cur_gun.resetZoom()


func _on_gun_fired():
	fillAmmoInfo(player.cur_gun)


func fillAmmoInfo(wpn):
	var format = "%d / %d"
	ammo_label.text = format % [wpn.bullets_in_mag, wpn.bullets]


func _on_hp_changed():
	hp_label.text = String(player.health)
	ap_label.text = String(player.armour)
	

func _on_zoom_pressed():
	if player.cur_gun:
		player.cur_gun.zoom()


func _on_next_gun_pressed():
	player.switchGun()


func _on_reload_pressed():
	player.cur_gun.reload()
	reload_progress_bar.show()
	tween.interpolate_property(reload_progress_bar, "value", 0, 100, player.cur_gun.reload_time)
	tween.start()


func _on_gun_reloaded():
	fillAmmoInfo(player.cur_gun)
	reload_progress_bar.hide()


func _process(_delta):
	if player.alive:
		if mov_joy.joystick_vector.length_squared() > 0.4:
			player.direction = -mov_joy.joystick_vector
		if aim_joy.joystick_vector.length_squared() > 0.4:
			var theta = (-aim_joy.joystick_vector).angle() + PI / 2
			if theta > PI:
				theta = theta - 2 * PI 
			player.rotation = theta
		if aim_joy.joystick_vector.length_squared() > 0.8:
			if player.cur_gun:
				player.cur_gun.fireGun()


func hide():
	get_node("hud").hide()


func show():
	get_node("hud").show()
