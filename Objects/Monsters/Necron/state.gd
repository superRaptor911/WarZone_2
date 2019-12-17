extends Node

var object

var go_to_main_dest = preload("res://Objects/Monsters/Necron/mainDest.gd").new()
var attack_enimies = preload("res://Objects/Monsters/Necron/attack.gd").new()
var current_state = go_to_main_dest

func _ready():
	current_state = go_to_main_dest
	

func _init(O):
	object = O
	go_to_main_dest.object = O
	attack_enimies.object = O
	go_to_main_dest.next_states.push_back(attack_enimies)
	attack_enimies.next_states.push_back(go_to_main_dest)


func execState(delta):
	if current_state == null:
		return
	current_state.exec(delta)
	current_state = current_state.chkNewState()
