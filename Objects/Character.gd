#Base node for all movable characters
class_name Character
extends KinematicBody2D

export var HP : float = 100
export var AP : float = 100
export var speed : float = 80
export var melee_damage : float = 300

var alive : bool = true
var paused : bool = false
var movement_vector : Vector2
var team : Team = null
var close_chars = Array()


onready var model : Model = $Model
onready var movementNode = $movmtCPP
onready var level = get_tree().get_nodes_in_group("Level")[0]

var blood_spash_scn = preload("res://Objects/Graphics/bloodSplashDefault.tscn")

signal char_killed
signal char_born
signal char_took_damage
signal char_fraged(self_ref, victim_ref, wpn_name)

#Note : P_ = peer, S_ = server only


func _ready():
	emit_signal("char_born")
	


#process Character
func _process(delta):
	if alive and not paused:
		# handele movement
		movementNode.movement(delta)
	else:
		model.is_walking = false
	

#Take damage from some weapon used by someone
func takeDamage(damage : float, weapon : String, attacker_id : String):
	if HP <= 0 or not ( alive and get_tree().is_network_server() ):
		return
	
	var _attacker_data = game_server._unit_data_list.get(attacker_id)
	
	#reference to attacker
	var attacker_ref = null
	
	#Attacker exist.
	if _attacker_data:
		attacker_ref = _attacker_data.ref
	
	#check if friendly fire	
	if not (game_server.extraServerInfo.friendly_fire):
		if attacker_ref and team.team_id == attacker_ref.team.team_id:
			return
	
	#Damage distribution
	if AP > 0:
		AP = max(0,AP - 0.75 * damage)
		HP = max(0,HP - 0.25 * damage)
	else:
		HP = max(0,HP - damage)
	
	# Sync with peers
	rpc_unreliable("P_health",HP,AP)
	
	#char dead
	if HP <= 0:
		game_server.rpc("P_handleKills",name,attacker_id,weapon)
		
		if attacker_ref:
			# attacker_ref.emit_signal("char_fraged", 0)
			attacker_ref.emit_signal("char_fraged", attacker_ref, self, weapon)
		# sync with everyone
		rpc("P_death")


func killChar():
	if not alive:
		return
	HP = 0 
	AP = 0
	rpc("P_health",HP,AP)
	rpc("P_death")


var blood_spilled_timestamp = 0
var blood_spill_interval = 1000 #in ms

# Function to sync health
remotesync func P_health(hp,ap):
	HP = hp
	AP = ap
	if game_states.game_settings.particle_effects and (
	blood_spilled_timestamp + blood_spill_interval < OS.get_ticks_msec()):
		var splash = blood_spash_scn.instance()
		splash.rotation = rotation
		splash.global_position = global_position
		level.add_child(splash)
		blood_spilled_timestamp = OS.get_ticks_msec()
	emit_signal("char_took_damage")


# Function to sync death
remotesync func P_death():
	# scream chance 1/4 
	if randi() % 4 == 0:
		$die.play()
	alive = false
	model.set_deferred("disabled",true)
	$dtween.interpolate_property(model,"modulate",Color8(255,255,255,255),Color8(255,255,255,0),
		6,Tween.TRANS_LINEAR,Tween.EASE_IN,3)
	$dtween.start()
	emit_signal("char_killed")


func teleportCharacter(_pos,_input_id):
	return


func _on_close_range_body_entered(body):
	if body.is_in_group("Actor"):
		close_chars.append(body)


func _on_close_range_body_exited(body):
	if body.is_in_group("Actor"):
		close_chars.erase(body)


func performMeleeAttack():
	if model.doMelee():
		rpc_id(1,"serverMeleeAttack")


remotesync func serverMeleeAttack():
	for i in close_chars:
		if game_server.extraServerInfo.friendly_fire or (i.team.team_id != team.team_id):
			i.takeDamage(melee_damage, "melee", name)


remotesync func syncMelee():
	model.doMelee()


func _on_respawn_timer_timeout():
	pass
