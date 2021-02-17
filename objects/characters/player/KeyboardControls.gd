extends Node

onready var player = get_parent()


func _ready():
	if player && !player.is_in_group("Players"):
		player = null


func getInputs():
	if !player.is_network_master():
		return
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed('ui_up'):
		input_vector.y += -1
	if Input.is_action_pressed('ui_down'):
		input_vector.y += +1
	if Input.is_action_pressed('ui_left'):
		input_vector.x += -1
	if Input.is_action_pressed('ui_right'):
		input_vector.x += +1

	if player:
		player.direction = input_vector


func _process(_delta):
	getInputs()
