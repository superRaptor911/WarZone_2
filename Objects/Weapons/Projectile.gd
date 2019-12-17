extends Area2D

var velocity : float
var velocity_vector : Vector2
var damage : float
var sender
var weapon


func _ready():
	pass # Replace with function body.


func create_bullet(var pos : Vector2,var rot : float, var v : float,dam : float,wpn,sen):
	position = pos
	velocity = v
	rotation = rot
	velocity_vector.x = velocity*cos(rot-1.57)
	velocity_vector.y = velocity*sin(rot - 1.57)
	damage = dam
	$Time_to_live.start()
	sender = sen
	weapon = wpn


func _process(delta):
	position += velocity_vector * delta


func _on_Time_to_live_timeout():
	queue_free()


func _on_Projectile_body_entered(body):
	if body.is_in_group("Actor"):
		body.takeDamage(damage,weapon,sender)
	queue_free()