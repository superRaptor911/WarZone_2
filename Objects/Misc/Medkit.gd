extends Sprite


var item_id = 0

var item_data = {
	type = "med",
	pos = Vector2()
}

signal item_expired(id)

func create(info):
	item_data = info
	position = item_data.pos + Vector2(32,32)
	$Timer.start()


func _on_Timer_timeout():
	emit_signal("item_expired",item_id)
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("User") and body.is_network_master():
		if body.HP < 100:
			body.pickItem(item_id)


remotesync func itemPicked():
	$AudioStreamPlayer2D.play()
	hide()


func _on_AudioStreamPlayer2D_finished():
	queue_free()
