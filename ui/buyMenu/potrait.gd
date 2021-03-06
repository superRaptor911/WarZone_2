extends TextureRect

onready var par = get_parent().get_parent()
onready var next_gun_btn = get_node("next_gun")
onready var prev_gun_btn = get_node("prev_gun")
onready var gun_name_label = get_node("gun_name")

var current_type : String = ""
var current_index : int = 0

func _ready():
	_connectSignals()


func _connectSignals():
	par.connect("pistol_pressed", self, "_on_pistol_pressed")


func _on_pistol_pressed():
	current_type = "pistol"
	current_index = 0
	loadGun(current_index)


func loadGun(index : int):
	var data = par.data.get(current_type)[index]
	texture = load(data.potrait)
	gun_name_label.text = data.name
	print("Loading gun")
