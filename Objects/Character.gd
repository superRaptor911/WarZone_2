extends KinematicBody2D

export var HP : float = 100
export var AP : float = 100
export var alive : bool = true
export var speed : float = 80
export var stamina : float = 1


var movement_vector : Vector2	#
var speed_multiplier : float = 1 	#speed multiplier 
var team : bool = true

#last attacked entity
var last_attacker
var skin : Model
signal char_killed
signal char_took_damage

##################PRIVATE##########################

func _ready():
	skin = $Model
	remove_child($Model)
	add_child(skin)
	
	

func _process(delta):
	if alive:
		_movement(delta)
		_regain_stamina()
		if HP < 40:
			$bloodSpot.emitting = true
		else:
			$bloodSpot.emitting = false
	else:
		if skin:
			skin.is_walking = false

func _emit_blood():
	if HP < 40:
		if $bloodSpot:
			$bloodSpot.emitting = true
	else:
		if $bloodSpot:
			$bloodSpot.emitting = false
#This function handles character movement
#movement is done by manuplulating movement_vector
func _movement(delta : float):
	if movement_vector.length() > 0:
		skin.is_walking = true
		skin.multiplier = speed_multiplier
	else:
		skin.is_walking = false
	if is_network_master():
		movement_vector = movement_vector.normalized()
		move_and_slide(movement_vector * speed  * speed_multiplier)
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
	rpc("sync_health",HP,AP)
	if HP == 0:
		if attacker:
			if attacker.is_in_group("User"):
				attacker.kills += 1
		if self.is_in_group("User"):
			hide()
			self.deaths += 1
		alive = false
		emit_signal("char_killed")
		rpc("sync_killStats")

#emit blood when injured
#server function
func _blood_splash(p1,p2):
	var angle = (p2-p1).angle()
	#if enabled then emit
	if $bloodSplash:
		$bloodSplash.global_rotation = angle
		$bloodSplash.emitting = true
	rpc_unreliable("_sync_blood_splash",angle)

#peer function for emission of blood when injured
remote func _sync_blood_splash(angle):
	if $bloodSplash:
		$bloodSplash.global_rotation = angle
		$bloodSplash.emitting = true

remote func sync_health(hp,ap):
	HP = hp
	AP = ap
	
remote func sync_killStats():
	hide()
	if last_attacker != null:
		if last_attacker.is_in_group("User"):
			last_attacker.kills += 1
	if self.is_in_group("User"):
		self.deaths += 1
	alive = false
	emit_signal("char_killed")




func _on_free_timer_timeout():
	queue_free()


func _on_Character_char_took_damage():
	if HP < 40:
		$bloodSpot.emitting = true
