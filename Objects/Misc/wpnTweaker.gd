extends Control

onready var rof 	= $Panel/VBoxContainer/Rof/HSlider
onready var rec 	= $Panel/VBoxContainer/rec/HSlider
onready var sprd 	= $Panel/VBoxContainer/sprd/HSlider
onready var dam 	= $Panel/VBoxContainer/dam/HSlider

var plr = null
var counter = true

func _ready():
	plr = get_tree().get_nodes_in_group("User")[0]
	plr.connect("gun_loaded", self, "on_gun_loaded")
	plr.connect("gun_switched", self, "on_gun_loaded")
	plr.connect("gun_picked", self, "on_gun_changed")
	on_gun_loaded()

	$Panel/VBoxContainer/Rof.connect("value_changed", self, "applyUpdate")
	$Panel/VBoxContainer/rec.connect("value_changed", self, "applyUpdate")
	$Panel/VBoxContainer/sprd.connect("value_changed", self, "applyUpdate")
	$Panel/VBoxContainer/dam.connect("value_changed", self, "applyUpdate")


func on_gun_loaded():
	counter = false
	dam.value 	= plr.selected_gun.damage
	rof.value 	= plr.selected_gun.rate_of_fire
	rec.value 	= plr.selected_gun.recoil_factor
	sprd.value	= plr.selected_gun.spread  * 180 / PI
	counter = true
	print("new gun")




func applyUpdate():
	if not counter:
		return
	plr.selected_gun.damage = dam.value
	plr.selected_gun.spread = sprd.value * PI / 180
	plr.selected_gun.recoil_factor	= rec.value
	plr.selected_gun.rate_of_fire	= rof.value
	print("Applying update")
		

func _on_print_pressed():
	var format = "{ cost =  %d, dmg = %d, rof = %d, rec = %.2f, sprd = %d }"
	print(format % [plr.selected_gun.wpn_cost, dam.value, rof.value, rec.value, sprd.value])
