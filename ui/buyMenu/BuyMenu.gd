extends Control

onready var purchase_btn   = get_node("Panel/potrait/purchase")
onready var cash_label     = get_node("Panel/cash")
onready var back_btn       = get_node("back")

onready var pistol_btn = get_node("Panel/container/pistol")
onready var smg_btn = get_node("Panel/container/smg")
onready var rifle_btn = get_node("Panel/container/rifle")
onready var mg_btn = get_node("Panel/container/mg")

signal pistol_pressed
signal smg_pressed
signal rifle_pressed
signal mg_pressed

var data = {
	pistol = [],
	smg = [],
	mg = [],
	rifle = []
	}

func _ready():
	_connectSignals()
	loadData()
	_on_pistol_pressed()


func _connectSignals():
	back_btn.connect("pressed", self, "_on_back_button_pressed")
	pistol_btn.connect("pressed", self, "_on_pistol_pressed")
	smg_btn.connect("pressed", self, "_on_smg_pressed")
	rifle_btn.connect("pressed", self, "_on_rifle_pressed")
	mg_btn.connect("pressed", self, "_on_mg_pressed")

	purchase_btn.connect("pressed", self, "_on_purchase_pressed")


func _on_pistol_pressed():
	emit_signal("pistol_pressed")


func _on_smg_pressed():
	emit_signal("smg_pressed")


func _on_rifle_pressed():
	emit_signal("rifle_pressed")


func _on_mg_pressed():
	emit_signal("mg_pressed")


func _on_purchase_pressed():
	pass


func loadData():
	var resource = get_node("/root/Resources")
	for i in resource.gun_stats:
		var gun = resource.gun_stats.get(i)
		if gun.type == "pistol":
			data.pistol.append(gun)
		elif gun.type == "smg":
			data.smg.append(gun)
		elif gun.type == "rifle":
			data.rifle.append(gun)
		elif gun.type == "mg":
			data.mg.append(gun)


func _on_back_button_pressed():
	queue_free()
