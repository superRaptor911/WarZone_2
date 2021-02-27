extends KinematicBody2D

var health : float      = 100
var armour : float      = 0
var speed : float       = 100.0
var direction : Vector2 = Vector2(0,0)
var alive : bool        = true
var team_id : int		= -1
var nick : String       = "Entity"

signal entity_took_damage(attacker_name)
signal entity_killed(victim_name, killer_name, weapon_name)
signal entity_fraged(killer_name, victim_name, weapon_name)

func _ready():
	pass # Replace with function body.


func takeDamage(damage : float, penetration_ratio : float = 1, attacker : String = "", wpn_name : String = ""):
	if alive:
		if armour != 0:
			damage *= penetration_ratio
			armour = max(0, armour - damage * 0.1)
		health = max(0, health - damage)
		emit_signal('entity_took_damage', attacker)
		# Handle Death
		if health == 0:
			alive = false
			emit_signal('entity_killed',name, attacker, wpn_name)	# killed signal
			var attacker_ref = findEntity(attacker)
			if attacker_ref:
				emit_signal("entity_fraged", attacker, name, wpn_name)	# frag signal


func findEntity(entity_name):
	if entity_name == "":
		return null
	# Wrong code, must be changed asap
	var teams = get_tree().get_nodes_in_group("Teams")
	for i in teams:
		var entity = i.players.get(entity_name)
		if entity:
			return entity
	print("Entity::Failed to find entity " + entity_name)
	return null


func heal(value : float):
	health += value


func teleport(pos : Vector2):
	get_node("movement").teleport(pos)
