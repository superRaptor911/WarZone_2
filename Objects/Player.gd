extends "res://Objects/Character.gd"

class_name Player

export var regen_rate : float = 10
var primary_gun = null
var sec_gun = null
var selected_gun : Gun


var kills : int = 0
var deaths : int = 0
var pname : String


var frames : float = 0
var timer_time : float = 0
var hud

var grenade = preload("res://Objects/Weapons/grenade.tscn")
var grenade_count = 3
var _pause_cntrl : bool = false

###################################################


func _ready():
	$Gun.queue_free()
	if is_network_master():
		pname = game_states.player_info.name
		$Camera2D.current = true
		$Timer.start()
		var cnt_path = game_states.control_types.get(game_states.game_settings.control_type)
		var controller = load(cnt_path).instance()
		controller.set_name("controller")
		add_child(controller)
		controller.user = self
		connect("char_killed",self,"_on_player_killed")
		hud = load("res://Menus/HUD/Hud.tscn").instance()
		hud.setUser(self)
		add_child(hud)
		hud.get_node("respawn").max_value = 4.0


func _on_player_killed():
	#show respawn percentage
	hud.get_node("respawn").visible = true
	$Camera2D.current = false
	$free_timer.start()
	pause_controls(true)



func load_guns(nam : String , nam2 : String):
	var g = game_states.weaponResource[nam].instance()
	var g2 = game_states.weaponResource[nam2].instance()
	if primary_gun:
		primary_gun.queue_free()
	primary_gun = g
	if sec_gun:
		sec_gun.queue_free()
	sec_gun = g2
	
	if not skin:
		selected_gun = primary_gun
		return
	skin.get_node("Skeleton2D/boneBody/armr/hand/fist").remove_child(selected_gun)
	selected_gun = primary_gun
	skin.get_node("Skeleton2D/boneBody/armr/hand/fist").add_child(selected_gun)
	selected_gun.connect("gun_fired",skin,"_on_gun_fired")
	#selected_gun.position = $Model.get("fist").position



func _process(delta):
	HP = min(100,HP + regen_rate * delta)
	_get_inputs()
	if is_network_master():
		if not alive:
			hud.get_node("respawn").value += delta
		$CanvasModulate.color = Color8(255,2.55 * HP,2.55 * HP)


func _get_inputs():
	if not is_network_master():
		return
	frames += 1
	if game_states.is_android or _pause_cntrl:
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
	if Input.is_action_pressed("ui_sprint"):
		useSprint()
	if Input.is_action_just_pressed("ui_spl"):
		throwGrenade()
	if Input.is_action_just_pressed("ui_next_item"):
		rpc("switchGun")
	if Input.is_action_just_pressed("ui_inv"):
		pause_controls(true)
		var inv_menu = load("res://Menus/Inventory/inventory_menu.tscn").instance()
		get_tree().root.add_child(inv_menu)
	
	rotation = (get_global_mouse_position()  - global_position).angle() + 1.57

remote func throwGrenade():
	if get_tree().is_network_server():
		var g = grenade.instance()
		var nam = "g" + String(randi()%1000)
		g.set_name(nam)
		get_tree().root.add_child(g)
		var dir = (skin.get_node("Skeleton2D/boneBody/armr/hand/fist").global_position - global_position).normalized()
		g.position = position + (Vector2(-1.509,-50.226)).rotated(rotation)
		g.user = self
		g.throwGrenade(dir)
		rpc("_sync_throwGrenade",nam)
	else:
		rpc_id(1,"throwGrenade")

remote func _sync_throwGrenade(nam):
	var g = grenade.instance()
	g.set_name(nam)
	get_tree().root.add_child(g)
	var dir = (skin.get("fist").global_position - global_position).normalized()
	g.position = position + (Vector2(-1.509,-50.226)).rotated(rotation)
	g.user = self
	g.throwGrenade(dir)

#sync 




sync func respawn_player(pos,id):
	show()
	alive = true
	HP = 100
	AP = 100
	pause_controls(false)
	#teleportCharacter(pos,_input_id)
	load_guns(network.players[id].primary_gun_name,network.players[id].sec_gun_name)

remotesync func switchGun():
	skin.switchGun(selected_gun.gun_type)
	if selected_gun == primary_gun:
		if sec_gun != null:
			skin.get_node("Skeleton2D/boneBody/armr/hand/fist").remove_child(selected_gun)
			selected_gun = sec_gun
			skin.get_node("Skeleton2D/boneBody/armr/hand/fist").add_child(selected_gun)
	else:
		skin.get_node("Skeleton2D/boneBody/armr/hand/fist").remove_child(selected_gun)
		selected_gun = primary_gun
		skin.get_node("Skeleton2D/boneBody/armr/hand/fist").add_child(selected_gun)
	
	selected_gun.connect("gun_fired",skin,"_on_gun_fired")
	selected_gun.position = Vector2(0,0)



func pause_controls(val : bool):
	_pause_cntrl = val
	if game_states.is_android:
		get_node("controller").enabled = !val
	

func _on_Timer_timeout():
	get_parent().get_node("CanvasLayer/Label").text = String(frames)
	frames = 0
	$Timer.start()


func _on_free_timer_timeout():
	hud.get_node("respawn").value = 0
	hud.get_node("respawn").visible = false
	var spawn_points
	for sp in get_tree().get_nodes_in_group("spawn_points"):
		spawn_points = sp.get_children()
	var id = randi() % spawn_points.size()
	alive = true
	HP = 100
	AP = 100
	position = spawn_points[id].position
	load_guns(game_states.player_info.primary_gun_name,game_states.player_info.sec_gun_name)
	$Camera2D.current = true
	rpc("respawn_player",spawn_points[id].position,game_states.player_info.net_id)
