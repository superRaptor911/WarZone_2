extends RigidBody2D

var gun_type : String = "explosive"

export var velocity : float = 200

#Loading explosive
var explo = preload("res://Objects/Weapons/Bomb.tscn").instance()
var decal = preload("res://Objects/Graphics/Decal.tscn").instance()
#user of this grenade
var user = ""

func _ready():
	
	#experimental (freeze collision for peer)
	if not get_tree().is_network_server():
		sleeping = true

#Explode grenade when timer timeout
func _on_Timer_timeout():
	explo.usr = user
	rpc("sync_explode")

#throw grenade towards "dir"  
func throwGrenade(dir):
	linear_velocity = dir * velocity
	$AnimationPlayer.play("throw")
	#start timer when grenade is thrown
	if get_tree().is_network_server():
		$Timer.start()



#sync grenade explosion
remotesync func sync_explode():
	decal.position = position
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.add_child(decal)
	explo.position = position
	level.add_child(explo)
	explo.explode()
	queue_free()

