#Player is a user controlled character
#group : User
class_name Player
extends "res://Objects/unit.gd"

var cash : int = 0

var timer_time : float = 0
var hud = null

var grenade = preload("res://Objects/Weapons/grenade.tscn")
var spectate = preload("res://Objects/Game_modes/Spectate.tscn").instance()
var _pause_cntrl : bool = false

var cur_dropped_item_id = 0

onready var canvas = get_node("CanvasModulate")

signal player_killed(player)
signal gun_picked


###################################################
#Note: free_timer is overridden to perform respawn
#
###################################################

func _ready():
	game_states.last_match_result.map = game_server.serverInfo.map
	game_states.last_match_result.cash = 0
	game_states.last_match_result.kills = 0
	game_states.last_match_result.death = 0
	game_states.last_match_result.xp = 0

	$Gun.queue_free()
	$tag/name_tag.text = pname
	connect("respawned",self,"on_player_respawned")
	
	if is_network_master():
		if game_states.game_settings.dynamic_camera:
			$Camera2D.position = Vector2(0,-150)
		
		$Camera2D.current = true
		connect("char_killed",self,"_on_player_killed")
		hud = load("res://Menus/HUD/Hud.tscn").instance()
		add_child(hud)
		hud.setUser(self)
		$aim_indicator.show()
	
	if get_tree().is_network_server():
		connect("char_killed",self,"_on_peer_killed")


func _on_player_killed():
	$Camera2D.current = false
	$aim_indicator.hide()
	pause_controls(true)

func pickItem(item_id = -1):
	var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
	if item_id == -1:
		d_item_man.rpc_id(1,"requestPickUp",name,cur_dropped_item_id)
	else:
		d_item_man.rpc_id(1,"requestPickUp",name,item_id)

remotesync func pickUpItem(item):
	if item.type == "wpn":
		var old_gun = selected_gun
		if selected_gun == gun_1:
			gun_1 = game_states.weaponResource.get(item.wpn).instance()
			gun_1.rounds_left = item.bul
			gun_1.clip_count = item.clps
			selected_gun = gun_1
		else:
			gun_2 = game_states.weaponResource.get(item.wpn).instance()
			gun_2.rounds_left = item.bul
			gun_2.clip_count = item.clps
			selected_gun = gun_2
		var d_item_man = get_tree().get_nodes_in_group("Level")[0].dropedItem_manager
		d_item_man.rpc_id(1,"serverMakeItem",wpn_drop.getWpnInfo(old_gun))
		old_gun.queue_free()
		setSelectedGun()
		emit_signal("gun_picked")
	elif item.type == "med":
		HP = 100
	elif item.type == "kevlar":
		AP = 100


func _on_peer_killed():
	emit_signal("player_killed",self)
	get_parent().add_child(spectate)
	remove_child(hud)
	

func getWpnAttachments():
	for i in game_states.player_data.guns:
		if i.gun_name == gun_1.gun_name:
			gun_1.laser_sight = i.laser
			gun_1.extended_mag = i.mag_ext
			gun_1.extendMag()
		if i.gun_name == gun_2.gun_name:
			gun_2.laser_sight = i.laser
			gun_2.extended_mag = i.mag_ext
			gun_2.extendMag()


func _process(delta):
	HP = min(100,HP + regen_rate * delta)
	_get_inputs()
	if is_network_master():
		canvas.color = Color(1.0, 0.01 * HP, 0.01 * HP)



func _get_inputs():
	if not is_network_master() or _pause_cntrl or game_states.is_android:
		return

	if Input.is_action_pressed("ui_fire"):
		selected_gun.fireGun()
	if Input.is_action_pressed("ui_down"):
		movement_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement_vector.x += 1
	if Input.is_action_just_pressed("ui_spl"):
		if game_states.player_data.nade_count > 0:
			game_states.player_data.nade_count -= 1
			rpc_id(1,"server_throwGrenade")
	if Input.is_action_just_pressed("ui_next_item"):
		rpc("switchGun")
	if Input.is_action_just_pressed("ui_inv"):
		performMeleeAttack()
		return
	if Input.is_action_just_pressed("drop"):
		pickItem()
	rotation = (get_global_mouse_position()  - global_position).angle() + 1.57


remotesync func server_throwGrenade():
	if get_tree().is_network_server():
		#bad code
		var nam = "g" + String(randi()%10000)
		rpc("_sync_throwGrenade",nam)
	else:
		print("Error : called on peer")

remotesync func _sync_throwGrenade(nam):
	var g = grenade.instance()
	g.set_name(nam)
	get_tree().get_nodes_in_group("Level")[0].add_child(g)
	var dir = (model.get("fist").global_position - global_position).normalized()
	g.position = position + (Vector2(-1.509,-50.226)).rotated(rotation)
	g.user = self
	g.throwGrenade(dir)

#called when player is respawned
func on_player_respawned():
	pause_controls(false)
	if is_network_master():
		$Camera2D.current = true
		$aim_indicator.show()
		get_parent().remove_child(spectate)
		add_child(hud)


func pause_controls(val : bool):
	_pause_cntrl = val
	if game_states.is_android and is_network_master():
		hud.get_node("controller").enabled = !val

