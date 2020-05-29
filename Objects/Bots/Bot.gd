class_name Bot
extends "res://Objects/unit.gd"

var level = null

var _near_bodies = Array()

var is_bomber = false
var is_on_bomb_site = false

signal bot_killed(bot)

var bot_data : Dictionary = {
	bot_g1 = "",
	bot_g2 = ""
}

###################################################
#Note: free_timer is overridden to perform respawn
#
###################################################

func _ready():
	if get_tree().is_network_server():
		level = get_tree().get_nodes_in_group("Level")[0]
		level.connect("player_removed",self,"_on_player_left_server")
		level.connect("bot_removed",self,"_on_player_left_server")
		$Brain.setBotDifficulty(game_server.bot_settings.bot_difficulty)
		$Brain.setGameMode(game_server.serverInfo.game_mode)
		$VisionTimer.wait_time = $VisionTimer.wait_time * (1.0 + rand_range(-0.5,0.5))
		$VisionTimer.start()
		connect("char_killed",self,"_on_bot_killed")
				
		if game_server.serverInfo.game_mode == "Bombing":
			var bomb_mode = get_tree().get_nodes_in_group("GameMode")[0]
			bomb_mode.connect("round_started",$Brain,"on_new_round_starts")
			bomb_mode.connect("bomber_selected",$Brain,"on_bomber_selected")
			bomb_mode.connect("bomb_planted",$Brain,"on_bomb_planted")
			bomb_mode.connect("bomb_dropped",$Brain,"on_bomb_dropped")
	else:
		$Brain.queue_free()


func _on_bot_killed():
	emit_signal("bot_killed",self)

func pickItem(item_id):
	if $buy_time.is_stopped():
		var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
		d_item_man.rpc_id(1,"requestPickUp",name,item_id)


remotesync func pickUpItem(item):
	if item.type == "wpn":
		var old_gun = selected_gun
		if selected_gun == gun_1:
			gun_1 = game_states.weaponResource.get(item.wpn).instance()
			gun_1.rounds_left = item.bul
			gun_1.clips = item.clps
			selected_gun = gun_1
		else:
			gun_2 = game_states.weaponResource.get(item.wpn).instance()
			gun_2.rounds_left = item.bul
			gun_2.clips = item.clps
			selected_gun = gun_2
		var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
		d_item_man.rpc_id(1,"serverMakeItem",wpn_drop.getWpnInfo(old_gun))
		old_gun.queue_free()
		setSelectedGun()
	elif item.type == "med":
		HP = 100
	elif item.type == "kevlar":
		AP = 100

########################bot vision####################

#handle player disconnection
func _on_player_left_server(plr):
	var old_size = _near_bodies.size()
	_near_bodies.erase(plr)
	
	#update vision if affected by player disconnection
	if old_size != _near_bodies.size():
		_on_VisionTimer_timeout()
	

func _on_vision_body_entered(body):
	if body.is_in_group("Actor"):
		_near_bodies.append(body)

func _on_vision_body_exited(body):
	if body.is_in_group("Actor"):
		_near_bodies.erase(body)

func _on_VisionTimer_timeout():
	$Brain.visible_enemies.clear()
	$Brain.visible_friends.clear()
	
	for i in _near_bodies:
		if i and i.alive:
			#raycast chks
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(position, i.position,
													[self], collision_mask)
			if result:
				if result.collider.name == i.name:
					if i.team.team_id != team.team_id:
						$Brain.visible_enemies.append(i)
					else:
						$Brain.visible_friends.append(i)
	$Brain.updateVision()
	

###################################Bot Bombing mode####################

func selectedAsbomber():
	$Brain.onSelectedAsBomber()

func _on_new_round_start():
	$Brain.onNewBombingRoundStarted()

func _on_bomb_planted():
	$Brain.onBombPlanted()

func _process(delta):
	$Brain.think(delta)

func plantBomb():
	get_tree().get_nodes_in_group("GameMode")[0]._on_plant_bomb_pressed()


func diffuseBomb():
	get_tree().get_nodes_in_group("GameMode")[0].rpc("_bombDiffused")
	
func canDiffuse():
	$Brain.onCTnearBomb()
