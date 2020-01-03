extends "res://Objects/custom_scripts/fsm_bot.gd"


var current_state = null

var _get_player = preload("res://Objects/custom_scripts/get_player.gd").new()
var _goto_player = preload("res://Objects/custom_scripts/goto_player.gd").new()
var _attack_player = preload("res://Objects/custom_scripts/necron_attack.gd").new()

func _ready():
	bot.add_child(_get_player)
	bot.add_child(_goto_player)
	bot.add_child(_attack_player)
	
	_get_player.connect("player_found",self,"_on_player_selected")
	_goto_player.connect("player_dead",self,"_on_player_killed")
	_goto_player.connect("player_visible",self,"_on_player_spotted")
	_attack_player.connect("player_dead",self,"_on_player_killed")
	_attack_player.connect("player_not_visible",self,"_on_player_selected")
	bot.connect("char_killed",self,"_on_bot_killed")
	current_state = _get_player
	_get_player.startState()
	

func setCurrentState(st):
	if current_state:
		current_state.stopState()
	current_state = st
	current_state.startState()
	print(current_state.state_name)

func _on_player_selected():
	setCurrentState(_goto_player)
	

func _on_player_killed():
	setCurrentState(_get_player)

func _on_bot_killed():
	_get_player.queue_free()
	_goto_player.queue_free()
	queue_free()
	
func _on_player_spotted():
	print("asas")
	setCurrentState(_attack_player)