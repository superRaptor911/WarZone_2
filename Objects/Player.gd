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
func _ready():
	$Gun.queue_free()
	skin.get_node("anim").current_animation = selected_gun.gun_type
	if is_network_master():
		pname = game_states.player_info.name
		$Camera2D.current = true
		$Timer.start()
		var cnt_path = game_states.control_types.get(game_states.game_settings.control_type)
		var controller = load(cnt_path).instance()
		add_child(controller)
		controller.user = self
		connect("char_killed",self,"_on_player_killed")
		hud = load("res://Menus/HUD/Hud.tscn").instance()
		hud.setUser(self)
		add_child(hud)
		hud.get_node("respawn").max_value = 4.0


func _on_player_killed():
	hud.get_node("respawn").visible = true
	$free_timer.start()



func load_guns(nam : String , nam2 : String):
	var g = game_states.weaponResource[nam].instance()
	var g2 = game_states.weaponResource[nam].instance()
	if primary_gun:
		primary_gun.queue_free()
	primary_gun = g
	if sec_gun:
		sec_gun.queue_free()
	sec_gun = g2
	
	remove_child(selected_gun)
	selected_gun = primary_gun
	add_child(selected_gun)
	selected_gun.position = $hand.position

	
	

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
	if game_states.is_android:
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

	rotation = (get_global_mouse_position()  - global_position).angle() + 1.57
	rpc("sync_vars",movement_vector,rotation,position)

func _on_cntrl_move(val):
	val *= 1/max(abs(val.x),abs(val.y))
	movement_vector = val
	rotation = val.angle() + 1.57
	rpc("sync_vars",movement_vector,rotation,position)
	


sync func sync_vars(vct,rot,pos):
	movement_vector = vct
	rotation = rot
	position = pos



sync func respawn_player(pos,id):
	show()
	alive = true
	HP = 100
	AP = 100
	position = pos
	load_guns(network.players[id].primary_gun_name,network.players[id].sec_gun_name)

func switchGun():
	if selected_gun == primary_gun:
		if sec_gun != null:
			remove_child(selected_gun)
			selected_gun = sec_gun
			skin.get_node("anim").current_animation = selected_gun.gun_type
	else:
		remove_child(selected_gun)
		selected_gun = primary_gun
		add_child(selected_gun)
		skin.get_node("anim").current_animation = selected_gun.gun_type




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
	rpc("respawn_player",spawn_points[id].position,game_states.player_info.net_id)
	
