extends KinematicBody2D

var health : float      = 100
var armour : float      = 0
var speed : float       = 100.0
var direction : Vector2 = Vector2(0,0)
var alive : bool        = true
var team_id : int		= -1
var nick : String       = "Entity"

signal entity_took_damage
signal entity_killed
# warning-ignore:unused_signal
signal entity_fraged
signal entity_revived
# warning-ignore:unused_signal
signal entity_destroyed

func _ready():
	Signals.emit_signal("entity_created", name)


func takeDamage(damage : float, penetration_ratio : float = 1, attacker : String = "", wpn_name : String = ""):
	if alive:
		# take damage
		if armour != 0:
			damage *= penetration_ratio
			armour = max(0, armour - damage * (1.1 - penetration_ratio))
		health = max(0, health - damage)
		emit_signal('entity_took_damage')

		# Sync with clients if server
		if get_tree().is_network_server():
			rpc("C_syncDamage", health, armour, attacker)

		# Handle Death
		if health == 0:
			alive = false
			Signals.emit_signal('entity_killed',name, attacker, wpn_name)	# killed signal
			emit_signal('entity_killed')
			var attacker_ref = findEntity(attacker)
			if attacker_ref:
				attacker_ref.emit_signal("entity_fraged")	# frag signal
			if get_tree().is_network_server():
				rpc("C_syncDeath", attacker, wpn_name)


func findEntity(entity_name):
	if entity_name == "":
		return null
	# Wrong code, must be changed asap
	var teams = get_tree().get_nodes_in_group("Teams")
	for i in teams:
		var entity = i.players.get(entity_name)
		if entity:
			return entity.ref
	print("Entity::Failed to find entity " + entity_name)
	return null


func heal(value : float):
	health += value


func teleport(pos : Vector2):
	get_node("movement").teleport(pos)


func reviveEntity():
	health = 100
	alive  = true
	emit_signal("entity_revived")
	Signals.emit_signal("entity_revived", name)


func _exit_tree():
	Signals.emit_signal("entity_destroyed", name)


# ............Networking..........................

remote func C_syncDamage(hp : int, ap : int, _attacker : String = ""):
	health = hp
	armour = ap
	emit_signal('entity_took_damage')


remote func C_syncDeath(attacker : String = "", wpn_name : String = ""):
	health = 0
	alive = false
	emit_signal('entity_killed')
	Signals.emit_signal('entity_killed',name, attacker, wpn_name)	# killed signal
	# emit signal for attacker
	var attacker_ref = findEntity(attacker)
	if attacker_ref:
		attacker_ref.emit_signal("entity_fraged")	# frag signal

