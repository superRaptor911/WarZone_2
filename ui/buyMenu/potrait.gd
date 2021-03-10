extends TextureRect

onready var par = get_parent().get_parent()
onready var next_gun_btn = get_node("next_gun")
onready var prev_gun_btn = get_node("prev_gun")
onready var gun_name_label = get_node("gun_name")
onready var purchase_btn = get_node("purchase") 


func _ready():
	_connectSignals()


func _connectSignals():
	par.connect("pistol_pressed", self, "_on_pistol_pressed")
	par.connect("smg_pressed", self, "_on_smg_pressed")
	par.connect("rifle_pressed", self, "_on_rifle_pressed")
	par.connect("mg_pressed", self, "_on_mg_pressed")
	next_gun_btn.connect("pressed", self, "_on_next_pressed") 
	prev_gun_btn.connect("pressed", self, "_on_prev_pressed") 


func _on_pistol_pressed():
	par.current_type = "pistol"
	par.current_index = 0
	loadGun(par.current_index)


func _on_smg_pressed():
	par.current_type = "smg"
	par.current_index = 0
	loadGun(par.current_index)


func _on_rifle_pressed():
	par.current_type = "rifle"
	par.current_index = 0
	loadGun(par.current_index)


func _on_mg_pressed():
	par.current_type = "mg"
	par.current_index = 0
	loadGun(par.current_index)


func _on_next_pressed():
	par.current_index += 1
	if par.current_index >= par.data.get(par.current_type).size():
		par.current_index = 0
	loadGun(par.current_index)


func _on_prev_pressed():
	par.current_index -= 1
	if par.current_index < 0:
		par.current_index = par.data.get(par.current_type).size() - 1
		return
	loadGun(par.current_index)


func loadGun(index : int):
	var data = par.data.get(par.current_type)[index]
	texture = load(data.potrait)
	gun_name_label.text = data.name
	purchase_btn.text = "$%d" % [data.cost]
