extends Area2D

export var radius : int = 100
export var team_id : int = 0
var entity_count : int = 0

func _on_spawn_point_body_entered(body):
	if body.is_in_group("Actor"):
		entity_count += 1

func _on_spawn_point_body_exited(body):
	if body.is_in_group("Actor"):
		entity_count -= 1

func getPoint() -> Vector2:
	entity_count += 1
	return (position + Vector2(rand_range(-radius,radius), rand_range(-radius,radius)))
