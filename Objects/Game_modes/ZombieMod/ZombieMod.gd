extends CanvasLayer

var Custom_teamSelector = "res://Objects/Game_modes/ZombieMod/Zm_TeamSelect.tscn"

var current_round = 0
var z_count = 0

var zombie_spawns = Array()
var selected_zombie_spawn = null
var is_player_playing = false

onready var tween =$Tween
onready var label = $Label



func showLabel(text : String, clr = Color.white):
	tween.interpolate_property(label, "modulate", Color(1,1,1,0) ,Color(1,1,1,1),
		1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	
	tween.interpolate_property(label, "modulate", Color(1,1,1,1) ,Color(1,1,1,0),
		1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 2)
	
	tween.start()
	label.text = text
	label.set("custom_colors/font_color", clr)


func _ready():
	if get_tree().is_network_server():
		
		zombie_spawns = get_tree().get_nodes_in_group("ZspawnPoints")[0].get_children()
		var teams = get_tree().get_nodes_in_group("Team")
		
		for i in teams:
			i.connect("team_eliminated", self, "on_team_eliminated")
		
		game_server.bot_settings.bot_count = 0
		
		var level = get_tree().get_nodes_in_group("Level")[0]
		level.connect("player_created", self, "on_player_created")
		

func on_player_created(_plr):
	if not is_player_playing:
		is_player_playing = true
		$round_start_dl.start()


func getZombieCount() -> int:
	return 10 + 5 * current_round



func on_team_eliminated(team):
	var team_id = team.team_id
	if team_id == 0:
		rpc("P_roundEnd")
		$round_start_dl.start()
		print("round end")
	else:
		$restart_delay.start()
		rpc("P_gameOver")
		print("game over")
	
	for i in zombie_spawns:
		i.deactivateZ()


func _on_round_start_dl_timeout():
	current_round += 1
	z_count = getZombieCount()
	rpc("P_roundStarted", current_round)
	
	var num = int(z_count / zombie_spawns.size())
	
	for i in zombie_spawns:
		i.max_zombies = num
		i.frequency = 0.75
		i.activateZ()



remotesync func P_roundStarted(r : int):
	showLabel("Round %d started. Get ready !!" % [r], Color.red)


remotesync func P_roundEnd():
	showLabel("You survived this wave.", Color.green)


remotesync func P_gameOver():
	showLabel("Humans eliminated, zombies win")


func _on_restart_delay_timeout():
	current_round = 0
	rpc("P_restart")


remotesync func P_restart():
	#remove existing zombies
	var zombies = get_tree().get_nodes_in_group("Monster")
	for i in zombies:
		i.queue_free()
	
	showLabel("New game starting")
