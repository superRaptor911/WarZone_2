extends Control

onready var player        = get_parent().get_parent()
onready var apply_btn     = get_node("Panel/Button")
onready var damage_slider = get_node("Panel/container/damage")
onready var recoil_slider = get_node("Panel/container/recoil")
onready var rof_slider    = get_node("Panel/container/rof")
onready var acc_slider    = get_node("Panel/container/acc")
onready var pen_slider    = get_node("Panel/container/pen") 
onready var giv_gun_edit  = get_node("LineEdit") 

func _ready():
	_connectSignals()


func _connectSignals():
	apply_btn.connect("pressed", self, "_on_apply_pressed")
	player.connect("gun_switched", self, "_on_gun_equiped")
	giv_gun_edit.connect("text_entered", self, "_on_text_entered")


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
	pen_slider.value = gun.penetration_ratio


func _applyStats():
	var gun = player.cur_gun
	gun.damage = damage_slider.value
	gun.rate_of_fire = rof_slider.value
	gun.recoil_factor = recoil_slider.value
	gun.accuracy = acc_slider.value
	gun.penetration_ratio = pen_slider.value
	gun.bullets = 100
	gun.bullets_in_mag = 100


func _saveData():
	var resource = get_node("/root/Resources")
	var stat = resource.gun_stats.get(player.cur_gun.wpn_name)
	var gun = player.cur_gun
	stat.damage = gun.damage
	stat.rate_of_fire = gun.rate_of_fire
	stat.recoil_factor = gun.recoil_factor
	stat.accuracy = gun.accuracy
	stat.penetration_ratio = gun.penetration_ratio
	Utility.saveDictionary("res://objects/guns/gun_stats.json", resource.gun_stats)



func _on_text_entered(text : String):
	var resource = get_node("/root/Resources")
	if resource.guns.has(text):
		player.equipGun(text)
	else:
		print("WeaponTweaker::Error::Gun not found")
