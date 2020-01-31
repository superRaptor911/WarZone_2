#main FSM controller for necrons
extends "res://Objects/custom_scripts/fsm_bot.gd"


var current_state = null

#state get nearest player
var _get_player = preload("res://Objects/custom_scripts/get_player.gd").new()
#state move towards nearest player
var _goto_player = preload("res://Objects/custom_scripts/goto_player.gd").new()
#state attack player
var _attack_player = preload("res://Objects/custom_scripts/necron_attack.gd").new()

func _ready():
	#add states
	bot.add_child(_get_player)
	bot.add_child(_goto_player)
	bot.add_child(_attack_player)
	
	#link states
	_get_player.connect("player_found",self,"_on_player_selected")
	_goto_player.connect("player_dead",self,"_on_player_killed")
	_goto_player.connect("player_visible",self,"_on_player_spotted")
	_goto_player.connect("update_target",self,"_on_player_killed")
	_attack_player.connect("player_dead",self,"_on_player_killed")
	_attack_player.connect("player_not_visible",self,"_on_player_selected")
	bot.connect("char_killed",self,"_on_bot_killed")
	
	#starting state (initial state)
	current_state = _get_player
	_get_player.startState()
	

#state changer
func setCurrentState(st):
	if current_state:
		current_state.stopState()
	current_state = st
	current_state.startState()

#when player is found swith to goto player
func _on_player_selected():
	setCurrentState(_goto_player)
	
#when player is killed find new player
func _on_player_killed():
	setCurrentState(_get_player)

#claer everything when bot dies
func _on_bot_killed():
	_get_player.queue_free()
	_goto_player.queue_free()
	_attack_player.queue_free()
	queue_free()

#swith state to attck when player is visible
func _on_player_spotted():
	setCurrentState(_attack_player)
