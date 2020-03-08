extends KinematicBody2D

export var HP : float = 100
export var AP : float = 100
export var alive : bool = true
export var speed : float = 80
export var stamina : float = 1


var movement_vector : Vector2	#
var speed_multiplier : float = 1 	#speed multiplier 
var team : Team = null
var current_time : float = 0
#last attacked entity
var last_attacker
var skin : Model = null

#This signal is emitted when char is killed
#it's better naming should be char_dead 
signal char_killed
signal char_took_damage
signal char_killed_someone

	
func _ready():
	#skin = $Model
	remove_child($Model)
	setSkin(game_states.modelResource.default_model.instance())
	#skin.set_name("skin")
	#add_child(skin)
	

#process Character
func _process(delta):
	if alive:
		#handele movement
		$movmtCPP.movement(delta)
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


#This function sets model
func setSkin(s):
	if s == null:
		print("Fucking error")
		return
	
	if skin != null:
		#if same skin return
		if skin.model_name == s.model_name:
			return
		
		#did for no good reason
		skin.set_name("x")
		#free previous skin
		skin.queue_free()
	#set new skin
	skin = s
	skin.set_name("skin")
	connect("char_killed",skin,"_on_killed")
	add_child(skin)
	
#increases movement speed
func useSprint():
	speed_multiplier = 1.3

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
	if team and not (game_states.GAME_MODE == "FFA"):
		if attacker:
			if team.team_id == attacker.team.team_id:
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

remotesync func sync_death():
	alive = false
	skin.set_deferred("disabled",true)
	$dtween.interpolate_property(skin,"modulate",null,Color8(255,255,255,0),6,Tween.TRANS_LINEAR,Tween.EASE_IN,3)
	$dtween.start()
	emit_signal("char_killed")

func _on_free_timer_timeout():
	queue_free()

func _on_Character_char_took_damage():
	if game_states.game_settings.particle_effects:
		if HP < 40:
			$bloodSpot.emitting = true

func teleportCharacter(pos,input_id):
	return
