extends Node2D

var velocity : float = 1000.0
var velocity_vector : Vector2
var pos_sign : Vector2
var final_dest : Vector2
var paused : bool = false


func _ready():
	pass # Replace with function body.


func create_bullet(var pos : Vector2,var rot : float, vel : float, fd : Vector2):
	position = pos
	velocity_vector = vel * (fd - pos).normalized()
	rotation = velocity_vector.angle() + 1.57
	final_dest = fd
	pos_sign.x = sign(final_dest.x - pos.x)
	pos_sign.y = sign(final_dest.y - pos.y)

func _process(delta):
	if not paused:
		position += velocity_vector * delta

func _on_Time_to_live_timeout():
	queue_free()

func _on_Projectile_body_entered(body):
	if body.is_in_group("Actor"):
		queue_free()
	else:
		$Sprite.hide()
		$impact.emitting = true
		paused = true
