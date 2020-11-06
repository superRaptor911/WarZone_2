#Player is a user controlled character
#group : User
class_name Player
extends "res://Objects/unit.gd"

var grenade_scn  = preload("res://Objects/Weapons/grenade.tscn")
var spectate 	 = preload("res://Objects/Game_modes/Spectate.tscn").instance()

# Stats
var cash : int 	 = 0
var xp : int	 = 0
var streak : int = 0

# Vars
var timer_time : float  = 0
var hud 				= null		# Hud referance
var team_selector 		= null		# team selector ref
var _pause_cntrl : bool = false		# Counter
var is_spectating 		= false		# Counter
var cur_dropped_item_id = 0			# Id for picking things

onready var canvas_modulate = get_node("CanvasModulate")

# Signals
signal player_killed(player)
signal gun_picked
signal entered_buy_zone
signal exited_buy_zone
#signal ammo_picked


func _ready():
	$Gun.queue_free()
	$tag/name_tag.text = pname
	connect("respawned",self,"on_player_respawned")
	
	if get_tree().is_network_server():
		connect("char_killed",self,"S_on_player_killed")
	
	if is_network_master():
		if game_states.game_settings.dynamic_camera:
			$Camera2D.position = Vector2(0,-120)
		
		$Camera2D.current = true
		connect("char_killed",self,"P_on_player_killed")
		hud = load("res://Menus/HUD/Hud.tscn").instance()
		add_child(hud)
		hud.setUser(self)
		$aim_indicator.show()
		
		var game_mode = get_tree().get_nodes_in_group("GameMode")[0]	
		var ts = game_mode.get("Custom_teamSelector")
		# Use custom team select
		if ts:
			team_selector = load(ts).instance()
		# Use default team select
		else:
			team_selector = load("res://Objects/Game_modes/BombDiffuse/BomTeamSelect.tscn").instance()
		# Connect signals
		team_selector.connect("team_selected", self, "P_on_team_selected")
		team_selector.connect("spectate_mode", self, "P_on_spectate_selected")
		
		game_states.match_result.map = game_server.serverInfo.map
		game_states.match_result.mode = game_server.serverInfo.game_mode


func P_on_player_killed():
	$Camera2D.current = false
	$aim_indicator.hide()
	pause_controls(true)
	streak = 0
	
	if not game_server.game_config.override_default_spectator:
		# Add spectate mode to level node after 2 seconds
		yield(get_tree().create_timer(2), "timeout")
		get_parent().add_child(spectate)
		# Connect signals
		spectate.connect("leave_spec_mode", self, "P_on_team_menu_selected")
		is_spectating = true
	
	remove_child(hud)
	game_states.match_result.kills = kills
	game_states.match_result.deaths = deaths


# Pick item using item id from ground
func pickItem(item_id = -1):
	var d_item_man = level.dropedItem_manager
	if item_id == -1:
		d_item_man.rpc_id(1,"requestPickUp",name,cur_dropped_item_id)
	else:
		d_item_man.rpc_id(1,"requestPickUp",name,item_id)


# Pick up item
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
		var d_item_man = level.dropedItem_manager
		d_item_man.rpc_id(1,"serverMakeItem",wpn_drop.getWpnInfo(old_gun))
		old_gun.queue_free()
		setSelectedGun()
		emit_signal("gun_picked")
	elif item.type == "med":
		HP = 100
		# Update HP in hud
		if hud:
			hud.on_damaged()
	elif item.type == "kevlar":
		AP = 100
		# Update AP in hud
		if hud:
			hud.on_damaged()
	elif item.type == "ammo":
		selected_gun.clip_count = 4
		unselected_gun.clip_count = 4
		# Update clip count in hud
		if hud:
			hud.setClipCount(4)


func S_on_player_killed():
	emit_signal("player_killed",self)


# Called when change team pressed 
func P_on_team_menu_selected():
	get_parent().remove_child(spectate)
	get_parent().add_child(team_selector)
	#team_selector.connect("team_selected", self, "P_on_team_selected")
	#team_selector.connect("spectate_mode", self, "P_on_spectate_selected")


# Called when spectate mode selected
func P_on_spectate_selected():
	if not alive:
		get_parent().remove_child(team_selector)
		if not game_server.game_config.override_default_spectator:
			get_parent().add_child(spectate)
			is_spectating = true
	else:
		Logger.notice.showNotice(get_parent(), "OOPS!", "You are alive and you need to be dead to spectate")


# Called when Team is selected in change team menu
func P_on_team_selected(team_id):
	# New team selected
	if team_id != team.team_id:
		level.rpc_id(1,"S_changeUnitTeam", name, team_id)
		get_parent().remove_child(team_selector)
		#get_parent().add_child(spectate)
	else:
		get_parent().remove_child(team_selector)
		if not alive:
			get_parent().add_child(spectate)
		# Show Warning
		Logger.Log("Team not changed, You are already in selected team")
		Logger.notice.showNotice(get_parent(), "OOPS!", "You are already in selected team")



func _process(_delta):
	_get_inputs()


# Get input from keyboard
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
	if Input.is_action_just_pressed("zoom"):
		get_node("Camera2D").zoom = selected_gun.getNextZoom()
	rotation = (get_global_mouse_position()  - global_position).angle() + 1.57


remotesync func server_throwGrenade():
	if get_tree().is_network_server():
		#bad code
		var nam = "g" + String(randi()%10000)
		rpc("_sync_throwGrenade",nam)
	else:
		print("Error : called on peer")


# Sync grenade throw
remotesync func _sync_throwGrenade(nam):
	var g = grenade_scn.instance()
	g.set_name(nam)
	level.add_child(g)
	var dir = (model.get("fist").global_position - global_position).normalized()
	g.position = position + (Vector2(-1.509,-50.226)).rotated(rotation)
	g.user = self.name
	g.throwGrenade(dir)


# Called when player is respawned
func on_player_respawned():
	pause_controls(false)
	if is_network_master():
		$Camera2D.current = true
		$aim_indicator.show()
		get_parent().remove_child(spectate)
		add_child(hud)

# Pause cntrl
func pause_controls(val : bool):
	_pause_cntrl = val
	if game_states.is_android and is_network_master():
		hud.get_node("controller").enabled = !val

func enteredBuyZone():
	emit_signal("entered_buy_zone")

func exitedBuyZone():
	emit_signal("exited_buy_zone")