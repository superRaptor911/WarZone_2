extends Control

var is_selected = false
var seleted_item = null
var radius = [90,90]

onready var joy1 = $j1
onready var joy2 = $j2

signal controller_selected

var default_config = {
	j1 = {
		pos = [96, 452],
		out_size = 200,
		in_size = 160,
		radius = 90
	},
	
	j2 = {
		pos = [996, 452],
		out_size = 200,
		in_size = 160,
		radius = 90
	}
}

var config = {
	j1 = {
		pos = [0, 0],
		out_size = 0,
		in_size = 0,
		radius = 0
	},
	
	j2 = {
		pos = [0, 0],
		out_size = 0,
		in_size = 0,
		radius = 0
	}
}

func _ready():
	connect("controller_selected", self, "on_joy_selected")
	var _config = game_states.load_data("user://controls.dat", false)
	config = default_config.duplicate()
	game_states.safe_cpy_dict(config, _config)
	
	$j1.rect_position = Vector2(config.j1.pos[0], config.j1.pos[1])
	$j1.rect_size = Vector2.ONE * config.j1.out_size
	$j1.get_node("j2").rect_size = Vector2.ONE * config.j1.in_size
	radius[0] = float(config.j1.radius)
	
	$j2.rect_position = Vector2(config.j2.pos[0], config.j2.pos[1])
	$j2.rect_size = Vector2.ONE * config.j2.out_size
	$j2.get_node("j2").rect_size = Vector2.ONE * config.j2.in_size
	radius[1] = float(config.j2.radius)
	MenuManager.connect("back_pressed", self,"on_back_pressed")


func _on_j1_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		is_selected = event.pressed
		if event.pressed:
			seleted_item = $j1
			seleted_item.get_node("ColorRect").show()
			emit_signal("controller_selected")
		else:
			seleted_item.get_node("ColorRect").hide()

	elif seleted_item == joy1 and is_selected and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		seleted_item.rect_position += event.relative



func _on_j2_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		is_selected = event.pressed
		if event.pressed:
			seleted_item = $j2
			seleted_item.get_node("ColorRect").show()
			emit_signal("controller_selected")
		else:
			seleted_item.get_node("ColorRect").hide()
	
	elif seleted_item == joy2 and is_selected and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		seleted_item.rect_position += event.relative


func on_joy_selected():
	$settings.show()
	$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
	$settings/inner_ring.max_value = seleted_item.rect_size.x
	$settings/out_ring.value = seleted_item.rect_size.x
	$settings/inner_ring.value = seleted_item.get_node("j2").rect_size.x
	if seleted_item == $j1:
		$settings/radius.value = radius[0]
	else:
		$settings/radius.value = radius[1]
	#var radius = $settings/radius.value
	#seleted_item.get_node("ColorRect").rect_size = Vector2(radius, radius)



func _on_out_ring_value_changed(value):
	if seleted_item:
		seleted_item.rect_size = Vector2(value, value)
		$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
		$settings/inner_ring.max_value = seleted_item.rect_size.x
		var inner_ring = seleted_item.get_node("j2")
		inner_ring.rect_position = seleted_item.rect_size / 2 - inner_ring.rect_size / 2
		seleted_item.get_node("ColorRect").rect_size = seleted_item.rect_size


func _on_inner_ring_value_changed(value):
	if seleted_item:
		seleted_item.get_node("j2").rect_size = Vector2(value, value)
		$settings/out_ring.min_value = seleted_item.get_node("j2").rect_size.x
		$settings/inner_ring.max_value = seleted_item.rect_size.x
		var inner_ring = seleted_item.get_node("j2")
		inner_ring.rect_position = seleted_item.rect_size / 2 - inner_ring.rect_size / 2


func _on_radius_value_changed(value):
	if seleted_item:
		var pos = seleted_item.rect_size / 2 - seleted_item.get_node("j2").rect_size / 2
		var fpos = pos - Vector2(0, seleted_item.rect_size.x / 2) * value / 100.0 
		seleted_item.get_node("j2").rect_position = fpos
		if seleted_item == $j1:
			radius[0] = $settings/radius.value
		else:
			radius[1] = $settings/radius.value


func on_back_pressed():
	config.j1.pos[0] = $j1.rect_position.x
	config.j1.pos[1] = $j1.rect_position.y
	config.j1.out_size = $j1.rect_size.x
	config.j1.in_size = $j1.get_node("j2").rect_size.x
	config.j1.radius = radius[0]
	
	config.j2.pos[0] = $j2.rect_position.x
	config.j2.pos[1] = $j2.rect_position.y
	config.j2.out_size = $j2.rect_size.x
	config.j2.in_size = $j2.get_node("j2").rect_size.x
	config.j2.radius = radius[1]
	
	game_states.save_data("user://controls.dat", config, false)


func _on_reset_pressed():
	config = default_config.duplicate()
	
	$j1.rect_position = Vector2(config.j1.pos[0], config.j1.pos[1])
	$j1.rect_size = Vector2.ONE * config.j1.out_size
	$j1.get_node("j2").rect_size = Vector2.ONE * config.j1.in_size
	radius[0] = float(config.j1.radius)
	
	$j2.rect_position = Vector2(config.j2.pos[0], config.j2.pos[1])
	$j2.rect_size = Vector2.ONE * config.j2.out_size
	$j2.get_node("j2").rect_size = Vector2.ONE * config.j2.in_size
	radius[1] = float(config.j2.radius)
