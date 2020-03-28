extends Area2D


signal bomber_entered
signal bomber_left

func _ready():
	pass # Replace with function body.


func _on_bomb_site_body_entered(body):
	if body.is_in_group("bomber"):
		emit_signal("bomber_entered")


func _on_bomb_site_body_exited(body):
	if body.is_in_group("bomber"):
		emit_signal("bomber_left")
