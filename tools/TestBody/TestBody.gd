extends KinematicBody2D

var health = 100
var armour = 100

func takeDamage(damage : float, penetration_ratio : float = 1, _attacker : String = "", _wpn_name : String = ""):
	if armour != 0:
		damage *= penetration_ratio
		armour = max(0, armour - damage * (1.1 - penetration_ratio))
	health = max(0, health - damage)
	# Handle Death
	if health == 0:
		$Sprite.modulate = Color.red
		$Timer.start()
	$Label.text = "HP %d AP %d" % [health, armour]


func _on_Timer_timeout():
	armour = 100
	health = 100
	$Sprite.modulate = Color.white
	$Label.text = "HP %d AP %d" % [health, armour]

