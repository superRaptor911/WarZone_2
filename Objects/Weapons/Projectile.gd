extends Node2D

export var speed : float = 1500.0
var dir : Vector2
var dest : Vector2
var reached_dest : bool = false
var dir_sign : Vector2
var target_hit = true

func create_bullet(ipos, dpos, hit = false):
	position = ipos
	dir = (dpos - ipos).normalized()
	rotation = dir.angle() + PI / 2
	dest = dpos
	target_hit = hit
	speed = max((dpos -ipos).length() * 3.0,800)
	dir_sign = Vector2(sign(dpos.x - ipos.x) , sign(dpos.y - ipos.y))


func _process(delta):
	if not reached_dest:
		position += dir * speed * delta
		var cur_dir_sign = Vector2(sign(dest.x - position.x), sign(dest.y - position.y))
		
		if cur_dir_sign != dir_sign:
			position = dest
			reached_dest = true
			if target_hit:
				queue_free()
			else:
				$Sprite.hide()
				$impact.emitting = true


func _on_Time_to_live_timeout():
	queue_free()
