# Spectate Mode
extends CanvasLayer

onready var controller = get_node("Control/Joystick") 
onready var mode_btn = get_node("Control/Button") 
onready var hp_label = get_node("Control/hp") 
onready var ap_label = get_node("Control/ap") 
onready var camera = get_node("Camera2D") 
onready var exit_btn = get_node("Control/exit") 

var is_free_look = false
var players = {}
var cur_player = null
var speed = 300

signal exiting_spectate_mode

func _ready():
	_connectSignals()
	_getPlayers()
	findNewTarget()


func _connectSignals():
	mode_btn.connect("pressed", self, "_on_mode_btn_pressed") 
	exit_btn.connect("pressed", self, "_on_exit_btn_pressed") 
	var level = get_tree().get_nodes_in_group("Levels")[0]
	var spawn_manager = level.get_node("SpawnManager")
	spawn_manager.connect("player_created", self, "_on_player_created")


func _on_mode_btn_pressed():
	is_free_look = !is_free_look
	if !is_free_look:
		findNewTarget()


func _getPlayers():
	var plrs = get_tree().get_nodes_in_group("Units")
	for i in plrs:
		players[i.name] = i
		i.connect("entity_destroyed", self, "_on_player_destroyed")


func _on_player_destroyed(player_name : String):
	var find_new_target = false
	# Handle , if current player was destroyed
	if players[player_name] == cur_player:
		cur_player = null
		find_new_target = true
		print("Spectate::Current player was destroyed, looking for new one")
	players.erase(player_name)
	if find_new_target:
		findNewTarget()


func _on_player_created(plr_name : String):
	var plr = Utility.getPlayer(plr_name)
	players[plr_name] = plr


func _process(delta):
	if cur_player:
		camera.position = cur_player.position
	if is_free_look:
		camera.position += -controller.joystick_vector * speed * delta


func findNewTarget():
	for i in players:
		var plr = players.get(i)
		if plr.alive:
			cur_player = plr
			return
	cur_player = null
	is_free_look = true


func _on_exit_btn_pressed():
	emit_signal("exiting_spectate_mode")
	queue_free()
