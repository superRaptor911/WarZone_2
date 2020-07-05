extends Sprite

var item_id = 0

var item_data = {
	type = "wpn",
	wpn = "",
	bul = 0,
	clps = 0,
	pos = Vector2()
}

var gun_rating = 0

signal item_expired(id)

func create(info):
	item_data = info
	position = item_data.pos
	var wpn = game_states.weaponResource.get(item_data.wpn).instance()
	gun_rating = wpn.gun_rating
	texture = wpn.gun_d_img
	wpn.queue_free()
	$Timer.start()
	

func getWpnInfo(selected_gun, in_tree = true) -> Dictionary:
	item_data.wpn = selected_gun.gun_name
	item_data.bul = selected_gun.rounds_left
	item_data.clps = min(selected_gun.clip_count, 4)
	if in_tree:
		item_data.pos = selected_gun.global_position
	else:
		item_data.pos = selected_gun.position
	return item_data


func _on_Timer_timeout():
	emit_signal("item_expired",item_id)
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Unit") and body.is_network_master():
		if body.is_in_group("User"):
			var hud = get_tree().get_nodes_in_group("Hud")
			if not hud.empty():
				hud[0].get_node("pick").show()
			body.cur_dropped_item_id = item_id
		elif body.selected_gun.gun_rating < gun_rating:
			body.pickItem(item_id)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Unit") and body.is_network_master():
		if body.is_in_group("User"):
			if body.cur_dropped_item_id == item_id:
				var hud = get_tree().get_nodes_in_group("Hud")
				if not hud.empty():
					hud[0].get_node("pick").hide()


remotesync func itemPicked():
	$AudioStreamPlayer2D.play()
	hide()


func _on_AudioStreamPlayer2D_finished():
	queue_free()
