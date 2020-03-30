extends Sprite

var item_id = 0

var item_data = {
	type = "wpn",
	wpn = "",
	bul = 0,
	clps = 0,
	pos = Vector2()
}

signal item_expired(id)

func create(info):
	item_data = info
	position = item_data.pos
	texture = game_states.weaponResource.get(item_data.wpn).instance().gun_d_img
	$Timer.start()
	

func getWpnInfo(selected_gun) -> Dictionary:
	item_data.wpn = selected_gun.gun_name
	item_data.bul = selected_gun.rounds_left
	item_data.clps = selected_gun.clips
	item_data.pos = selected_gun.global_position
	return item_data


func _on_Timer_timeout():
	emit_signal("item_expired",item_id)
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("User") and body.is_network_master():
		get_tree().get_nodes_in_group("Hud")[0].get_node("pick").show()
		body.cur_dropped_item_id = item_id


func _on_Area2D_body_exited(body):
	if body.is_in_group("User") and body.is_network_master():
		if body.cur_dropped_item_id == item_id:
			get_tree().get_nodes_in_group("Hud")[0].get_node("pick").hide()


remotesync func itemPicked():
	queue_free()
