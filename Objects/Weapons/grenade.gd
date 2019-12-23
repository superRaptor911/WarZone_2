extends RigidBody2D
export var velocity : float = 200

#Loading explosive
var explo = preload("res://Objects/Weapons/Bomb.tscn").instance()
#user of this grenade
var user

func _ready():
	#experimental (freeze collision for peer)
	if not get_tree().is_network_server():
		sleeping = true

#Explode grenade when timer timeout
func _on_Timer_timeout():
	explo.position = position
	get_tree().root.add_child(explo)
	explo.usr = user
	explo.explode()
	rpc("sync_explode")
	queue_free()

#throw grenade towards "dir"  
func throwGrenade(dir):
	linear_velocity = dir * velocity
	#start timer when grenade is thrown
	if get_tree().is_network_server():
		$Timer.start()



#sync grenade explosion
remote func sync_explode():
	explo.position = position
	get_tree().root.add_child(explo)
	explo.explode()
	queue_free()
	



func _on_Area2D_body_entered(body):
	if body.is_in_group("Actor"):
		if get_tree().is_network_server():
			_on_Timer_timeout()