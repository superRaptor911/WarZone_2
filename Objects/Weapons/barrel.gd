extends StaticBody2D


export var HP = 100

#Loading explosive
var explo = preload("res://Objects/Weapons/Bomb.tscn").instance()
var decal = preload("res://Objects/Graphics/Decal.tscn").instance()



#Take damage from some weapon used by someone
func takeDamage(damage : float, _weapon : String, attacker_id : String):
	if HP <= 0 or not get_tree().is_network_server():
		return
		
	HP = max(0,HP - damage)
	
	#Explode
	if HP <= 0:
		explo.usr = attacker_id
		#sync with everyone
		rpc("P_syncExplode")


#sync grenade explosion
remotesync func P_syncExplode():
	decal.position = position
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.add_child(decal)
	explo.position = position
	explo.SCALE = 4
	level.add_child(explo)
	explo.explode()
	queue_free()
