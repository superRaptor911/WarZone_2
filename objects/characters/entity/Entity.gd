extends KinematicBody2D

var health : float      = 100
var speed : float       = 100.0
var direction : Vector2 = Vector2(0,0)
var alive : bool	= true

signal entity_took_damage(attacker_name)
signal entity_killed(killer_name)

func _ready():
	pass # Replace with function body.


func takeDamage(value : float):
	health = max(0, health - value)
	emit_signal('entity_took_damage', '')
	if health == 0:
		emit_signal('entity_killed', '')
		alive = false


func takeDamageFrom(value : float, attacker : String):
	health = max(0, health - value)
	emit_signal('entity_took_damage', attacker)
	if health == 0:
		emit_signal('entity_killed', attacker)


func heal(value : float):
	health += value
