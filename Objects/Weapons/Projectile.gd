extends Node2D

var velocity : float = 1000.0
var velocity_vector : Vector2
var pos_sign : Vector2
var final_dest : Vector2


func _ready():
	pass # Replace with function body.


func create_bullet(var pos : Vector2,var rot : float, vel : float, fd : Vector2):
	position = pos
	rotation = rot
	velocity = vel
	velocity_vector.x = velocity*cos(rot-1.57)
	velocity_vector.y = velocity*sin(rot - 1.57)
	final_dest = fd
	pos_sign.x = sign(final_dest.x - pos.x)
	pos_sign.y = sign(final_dest.y - pos.y)


func _process(delta):
	position += velocity_vector * delta
	var new_pos_sign : Vector2
	new_pos_sign.x = sign(final_dest.x - position.x)
	new_pos_sign.y = sign(final_dest.y - position.y)
	
	if new_pos_sign != pos_sign:
		queue_free()
	

func _on_Time_to_live_timeout():
	queue_free()

func _on_Projectile_body_entered(body):
	queue_free()
