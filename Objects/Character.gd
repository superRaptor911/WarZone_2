extends KinematicBody2D

export var HP : float = 100
export var AP : float = 100
export var alive : bool = true
export var speed : float = 80
export var stamina : float = 1


var movement_vector : Vector2	#
var speed_multiplier : float = 1 	#speed multiplier 
var team : bool = true
var current_time : float = 0
#last attacked entity
var last_attacker
var skin : Model
signal char_killed
signal char_took_damage

var _input_id : int = 0
var old_rot : float = 0
###################################################
class state_vector:
	var position : Vector2
	var rotation : float
	var input_id : int
	var movement_vector : Vector2
	var speed_multiplier : int
	
	func _init(Pos : Vector2,MV : Vector2,R : float,SM : int,ID : int):
		rotation = R
		input_id = ID
		movement_vector = MV
		speed_multiplier = SM
		position = Pos

var state_vector_array = Array()
###################################################

func _ready():
	skin = $Model
	remove_child($Model)
	add_child(skin)

func _process(delta):
	if alive:
		_movement(delta)
		_regain_stamina()
		_emit_blood_marks()
	else:
		if skin:
			skin.is_walking = false

func _emit_blood_marks():
	if game_states.game_settings.particle_effects:
		if HP < 40:
			$bloodSpot.emitting = true
		else:
			$bloodSpot.emitting = false

#This function handles character movement
#movement is done by manuplulating movement_vector
func _movement(delta : float):
	if not is_network_master():
		interpolate_rotation(delta)
	current_time += delta
	if (current_time < game_server.update_delta):
		return
	current_time -= game_server.update_delta
	#handle movement if this is master
	if is_network_master():
		if movement_vector.length() or (old_rot != rotation):
			old_rot = rotation
			_input_id += 1
			_client_process_vectors()
			if get_tree().is_network_server():
				_server_process_vectors(movement_vector,rotation,speed_multiplier,_input_id)
			else:
				rpc_id(1,"_server_process_vectors",movement_vector,rotation,speed_multiplier,_input_id)
	movement_vector = Vector2(0,0)
	speed_multiplier = 1

func _regain_stamina():
	if stamina != 1:
		stamina += 0.01
		stamina = min(1,stamina)


#This function sets model
func setSkin(s):
	if s == null:
		print("Fucking error")
		return
	if skin != null:
		skin.queue_free()
	skin = s
	add_child(skin)
	

func useSprint():
	if stamina > 0:
		stamina -= 0.01
		speed_multiplier = 1.75
		

func takeDamage(damage : float,weapon,attacker):
	last_attacker = attacker
	if not get_tree().is_network_server():
		return
	if not (game_states.GAME_MODE == game_states.GAME_MODES.FFA):
		if attacker:
			if team == attacker.team:
				return
	if not alive:
		return
	if AP > 0:
		AP = max(0,AP - 0.75 * damage)
		HP = max(0,HP - 0.25 * damage)
	else:
		HP = max(0,HP - damage)
	emit_signal("char_took_damage")
	_blood_splash(attacker.position,position)
	#sync with peers
	rpc("sync_health",HP,AP)
	if HP == 0:
		#sync with everyone
		rpc("sync_death")

#emit blood when injured
#server function
func _blood_splash(p1,p2):
	var angle = (p2-p1).angle()
	rpc_unreliable("_sync_blood_splash",angle)

#peer function for emission of blood when injured
remotesync func _sync_blood_splash(angle):
	if game_states.game_settings.particle_effects:
		$bloodSplash.global_rotation = angle
		$bloodSplash.emitting = true

remote func sync_health(hp,ap):
	HP = hp
	AP = ap

var rot_speed : float = 0

remotesync func sync_vectors(pos,rot,speed_mul,is_moving,mov_vct,input_id):
	if is_network_master():
		var S_VT = getStateVector(input_id)
		if S_VT:
			if (S_VT.position - pos).length() < 1.25: # tolerance error could occur
				removePreviousStateVectors(input_id)
			else:
				print(S_VT.position,pos)
				removePreviousStateVectors(input_id)
				computeStates(pos)
		return
	$ptween.interpolate_property(self,"position",position,pos,game_server.update_delta,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$ptween.start()
	rotation = rot
	if rot < 0 :
		rot += 6.28
	elif rot > 6.28:
		rot -= 6.28
	if rotation < 0:
		rotation += 6.28
	elif rotation > 6.28:
		rotation -= 6.28
	rot_speed = abs(rot - rotation) / game_server.update_delta
	
	#$rtween.interpolate_property(self,"rotation",rotation,rot,game_server.update_delta,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	#$rtween.start()
	skin.is_walking = is_moving
	skin.multiplier = speed_mul


remote func _server_process_vectors(mov_vct,rot,speed_mul,input_id):
	if get_tree().is_network_server():
		if is_network_master():
			var last_state = null
			if state_vector_array.size():
				last_state = state_vector_array.back()
				rpc("sync_vectors",last_state.position,last_state.rotation,speed_multiplier,skin.is_walking,mov_vct,input_id)
		else:
			var last_state = null
			if state_vector_array.size():
				last_state = state_vector_array.back()
			changeState(last_state,mov_vct,rot,speed_mul,input_id)
			if mov_vct.length():
				skin.multiplier = speed_mul
				skin.is_walking = true
			else:
				skin.is_walking = false
			if state_vector_array.size():
				rpc("sync_vectors",state_vector_array[state_vector_array.size() - 1].position,rot,speed_mul,skin.is_walking,mov_vct,input_id)

func _client_process_vectors():
	var last_state = null
	if state_vector_array.size():
		last_state = state_vector_array.back()
	changeState(last_state,movement_vector,rotation,speed_multiplier,_input_id)
	#if movement update position and animation
	if movement_vector.length():
		$ptween.interpolate_property(self,"position",position,state_vector_array[state_vector_array.size() - 1].position,game_server.update_delta,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$ptween.start()
		skin.multiplier = speed_multiplier
		skin.is_walking = true
	else:
		skin.is_walking = false

func changeState(initial_state : state_vector, mov_vct : Vector2, rot : float,speed_mul : float,input_id : int):
	#if no initial state compute as it is
	if not initial_state:
		move_and_collide(mov_vct.normalized() * speed_mul * speed * game_server.update_delta)
		state_vector_array.append(state_vector.new(position,mov_vct,rot,speed_mul,input_id))
		return
	#we need to append new state without changing position
	#save old position
	var old_position = position
	#set position as initial state pos
	position = initial_state.position
	#update
	move_and_collide(mov_vct.normalized() * speed_mul * speed * game_server.update_delta)
	var new_position = position
	#append new state
	state_vector_array.append(state_vector.new(new_position,mov_vct,rot,speed_mul,input_id))
	#revert back to old position
	position = old_position

remotesync func sync_death():
	hide()
	#potential bug (server's last_attacker may differ from peer's)
	if last_attacker != null:
		if last_attacker.is_in_group("User"):
			last_attacker.kills += 1
	if self.is_in_group("User"):
		self.deaths += 1
	alive = false
	emit_signal("char_killed")


func _on_free_timer_timeout():
	queue_free()

#This Function Rotates Bot with a constatant Rotational speed
func interpolate_rotation(delta : float):
	if not state_vector_array.size():
		return
	var _dest_angle : float = state_vector_array.back().rotation
	if abs(_dest_angle - rotation) <= 0.1:
		return
	#make angles in range (0,2pi)
	if _dest_angle < 0 :
		_dest_angle += 6.28
	if rotation < 0:
		rotation += 6.28
	if rotation > 6.28:
		rotation -= 6.28
		
	var aba : float = _dest_angle - rotation
	if abs(aba) <= 6.28 - abs(aba) :
		rotation += sign(aba) * rot_speed * delta
	else:
		rotation += -sign(aba) * rot_speed * delta


func _on_Character_char_took_damage():
	if game_states.game_settings.particle_effects:
		if HP < 40:
			$bloodSpot.emitting = true


func removePreviousStateVectors(ID : int):
	var new_array = Array()
	for v in state_vector_array:
		if v.input_id >= ID:
			new_array.append(v)
	state_vector_array = new_array

func getStateVector(ID : int) -> state_vector:
	for v in state_vector_array:
		if v.input_id == ID:
			return v
	return null
	
func computeStates(pos):
	position = pos
	for v in state_vector_array:
		v.position = position
		move_and_collide(v.movement_vector * speed * v.speed_multiplier * game_server.update_delta)
		