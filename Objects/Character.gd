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

#This signal is emitted when char is killed
#it's better naming should be char_dead 
signal char_killed
signal char_took_damage
signal char_killed_someone

#ID of input
var _input_id : int = 0
#old_rot variable is used for custom rotation interpolation
var old_rot : float = 0
#rot_speed variable is used for custom rotation interpolation
var rot_speed : float = 0
###################################################
#State of character
class state_vector:
	var position : Vector2
	var rotation : float
	var input_id : int
	var movement_vector : Vector2
	var speed_multiplier : int
	
	#Constructor
	func _init(Pos : Vector2,MV : Vector2,R : float,SM : int,ID : int):
		rotation = R
		input_id = ID
		movement_vector = MV
		speed_multiplier = SM
		position = Pos
	

#Array of previous states
var state_vector_array = Array()
###################################################

func _ready():
	skin = $Model
	remove_child($Model)
	add_child(skin)

#process Character
func _process(delta):
	if alive:
		#handele movement
		_movement(delta)
		#if character is injured emit blood
		_isInjured()
	else:
		if skin:
			skin.is_walking = false

func _isInjured():
	#emit blood only if pratricle effect is enabled
	if game_states.game_settings.particle_effects:
		if HP < 40:
			$bloodSpot.emitting = true
		else:
			$bloodSpot.emitting = false

#This function handles character movement
#movement is done by using movement_vector
func _movement(delta : float):
	#if Character is other peer interpolate its rotation
	#This is used because Tween node failed
	if not is_network_master():
		interpolate_rotation(delta)
	#use server update rate (default 25 Hz)
	#game update rate is default 60 Hz 
	current_time += delta
	if (current_time < game_server.update_delta):
		return
	current_time -= game_server.update_delta

	#handle movement locally if this is master
	if is_network_master():
		#detect change in inputs
		if movement_vector.length() or (old_rot != rotation):
			old_rot = rotation
			#update input ID
			_input_id += 1
			#locally update position (Client side prediction)
			_client_process_vectors()
			#Send input data to Server
			if get_tree().is_network_server():
				_server_process_vectors(movement_vector,rotation,speed_multiplier,_input_id)
			else:
				rpc_id(1,"_server_process_vectors",movement_vector,rotation,speed_multiplier,_input_id)
	#reset input vectors
	movement_vector = Vector2(0,0)
	speed_multiplier = 1


#This function sets model
func setSkin(s):
	if s == null:
		print("Fucking error")
		return
	if skin != null:
		skin.queue_free()
	skin = s
	add_child(skin)
	
#increases movement speed
func useSprint():
	speed_multiplier = 1.75

#Take damage from some weapon used by someone
func takeDamage(damage : float,weapon,attacker):
	#Do not take damage if dead
	if not alive:
		return
	#Register last attacker
	last_attacker = attacker
	#Rest of the code is only handled by server
	if not get_tree().is_network_server():
		return
	#disable friendly fire in moded other than FFA
	#will be replaced by something better in future
	if not (game_states.GAME_MODE == game_states.GAME_MODES.FFA):
		if attacker:
			if team == attacker.team:
				return
	#Damage distribution
	if AP > 0:
		AP = max(0,AP - 0.75 * damage)
		HP = max(0,HP - 0.25 * damage)
	else:
		HP = max(0,HP - damage)
		
	emit_signal("char_took_damage")
	#emit blood splash
	#works well with projectiles but fails with explosion
	#will be fixed
	_blood_splash(attacker.position,position)
	#sync with peers
	rpc("sync_health",HP,AP)
	if HP == 0:
		attacker.emit_signal("char_killed_someone")
		game_server.handleKills(self,attacker,weapon)
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

#sync vectors 
remotesync func sync_vectors(pos,rot,speed_mul,is_moving,input_id):
	#Do reconsilation if Character is master
	if is_network_master():
		#get stateVector from movement history (stateVector_array)
		var S_VT = getStateVector(input_id)
		if S_VT:
			#if no error remove previous stateVectors from movement history 
			if (S_VT.position - pos).length() < 1.25:
				removePreviousStateVectors(input_id)
			#if error correct error
			else:
				#used for debug will be removed soon
				print(S_VT.position,pos)
				removePreviousStateVectors(input_id)
				computeStates(pos)
		return
	#if Character is not master interpolate vectors
	$ptween.interpolate_property(self,"position",position,pos,game_server.update_delta,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$ptween.start()
	
	#Custom rotation interpolation
	#Tween node failed to produce desirable output So, Custom interpolation is used
	
	if rot < 0 :
		rot += 6.28
	elif rot > 6.28:
		rot -= 6.28
	if rotation < 0:
		rotation += 6.28
	elif rotation > 6.28:
		rotation -= 6.28
	rot_speed = abs(rot - rotation) / game_server.update_delta
	
	skin.is_walking = is_moving
	skin.multiplier = speed_mul
	if not get_tree().is_network_server():
		state_vector_array.append(state_vector.new(Vector2(),Vector2(),rot,0,0))


#Server side Input data processor
remote func _server_process_vectors(mov_vct,rot,speed_mul,input_id):
	#safety check is it really server or not
	if get_tree().is_network_server():
		#if it is server's Character no need to recompute vectors
		if is_network_master():
			var last_state = null
			if state_vector_array.size():
				last_state = state_vector_array.back()
				rpc("sync_vectors",last_state.position,last_state.rotation,speed_multiplier,skin.is_walking,input_id)
		#Compute Input data
		else:
			var last_state = null
			if state_vector_array.size():
				last_state = state_vector_array.back()
			changeState(last_state,mov_vct,rot,speed_mul,input_id)
			if state_vector_array.size():
				rpc("sync_vectors",state_vector_array[state_vector_array.size() - 1].position,rot,speed_mul,skin.is_walking,input_id)
	#oops Error
	else:
		print("Func (_server_process_vectors) called on peer")

#Client side Input processor
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

#state changer
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
	alive = false
	emit_signal("char_killed")


func _on_free_timer_timeout():
	queue_free()

#custom rotation interpolator
#This Function Rotates Bot with a constatant Rotational speed
func interpolate_rotation(delta : float):
	if not state_vector_array.size():
		return
	var _dest_angle : float = state_vector_array.back().rotation
	if abs(_dest_angle - rotation) <= 0.04:
		return

	#make angles in range (0,2pi)
	if _dest_angle < 0 :
		_dest_angle += 6.28
	if rotation < 0:
		rotation += 6.28
	if rotation > 6.28:
		rotation -= 6.28
	if abs(_dest_angle - rotation) <= rot_speed * delta or abs(6.28 - abs(_dest_angle - rotation) ) <= rot_speed * delta:
		rotation = _dest_angle
		return

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

#reconsile algorithm
func computeStates(pos):
	position = pos
	for v in state_vector_array:
		v.position = position
		move_and_collide(v.movement_vector * speed * v.speed_multiplier * game_server.update_delta)

func teleportCharacter(pos,input_id):
	position = pos
	state_vector_array.append(state_vector.new(position,Vector2(0,0),0,1,input_id))

