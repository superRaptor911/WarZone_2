extends Control

onready var player        = get_parent().get_parent()
onready var apply_btn     = get_node("Panel/Button")
onready var damage_slider = get_node("Panel/container/damage")
onready var recoil_slider = get_node("Panel/container/recoil")
onready var rof_slider    = get_node("Panel/container/rof")
onready var acc_slider    = get_node("Panel/container/acc")

func _ready():
	_connectSignals()


func _connectSignals():
	apply_btn.connect("pressed", self, "_on_apply_pressed")
	player.connect("gun_switched", self, "_on_gun_equiped")


func _on_apply_pressed():
	_applyStats()
	_saveData()


func _on_gun_equiped():
	fillData()


func fillData():
	var gun = player.cur_gun
	damage_slider.value = gun.damage
	rof_slider.value = gun.rate_of_fire
	recoil_slider.value = gun.recoil_factor
	acc_slider.value = gun.accuracy


func _applyStats():
	var gun = player.cur_gun
	gun.damage = damage_slider.value
	gun.rate_of_fire = rof_slider.value
	gun.recoil_factor = recoil_slider.value
	gun.accuracy = acc_slider.value
	gun.bullets = 100
	gun.bullets_in_mag = 100


func _saveData():
	pass
