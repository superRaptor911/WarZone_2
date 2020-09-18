extends Sprite

var bomb_planted = false
var explosion = preload("res://Objects/Weapons/Bomb.tscn")
var usr = ""

var bomb_dropped = false

signal bomb_planted
signal bomb_exploded
signal bomb_diffused

signal bomb_picked(plr)
signal diffuser_entered(plr)
signal diffuser_left(plr)

func _ready():
	position = Vector2(-999,-999)


func activateBomb(pos):
	if get_tree().is_network_server() and not bomb_planted:
		bomb_planted = true
		rpc("bombPlanted",pos)
		emit_signal("bomb_planted")
	else:
		print_debug("Bomb already planted or called in peer")


func diffuseBomb():
	if bomb_planted:
		bomb_planted = false
		rpc("bombDiffused")
		emit_signal("bomb_diffused")
	else:
		print_debug("Bomb already diffused or not planted")


func dropBomb(pos):
	bomb_dropped = true
	rpc("bombDroped",pos)


func _on_Timer_timeout():
	rpc("bombExploded")
	emit_signal("bomb_exploded")


func _on_bom_beep_timeout():
	$bomb_timer.play()
	var beep_time = 0.1 + ($Timer.time_left / $Timer.wait_time)
	$Tween.interpolate_property($c4indicator,"modulate",Color(1.0,1.0,0.549),
		Color(0,0,0,0),beep_time,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
	$bomb_timer/bom_beep.start(beep_time)


func _on_Area2D_body_entered(body):
	if bomb_planted and body.is_in_group("Unit") and body.team.team_id == 1:
		emit_signal("diffuser_entered",body)
	
	if get_tree().is_network_server():
		if bomb_dropped and body.is_in_group("Unit") and body.team.team_id == 0:
			emit_signal("bomb_picked",body)
			rpc("pickBomb")



func _on_Area2D_body_exited(body):
	if bomb_planted and body.is_in_group("Unit") and body.team.team_id == 1:
		emit_signal("diffuser_left",body)


####################Remote###########################

remotesync func bombPlanted(pos):
	$Timer.start()
	show()
	$bomb_timer/bom_beep.start()
	position = pos
	$c4indicator.show()


remotesync func bombDroped(pos):
	$Area2D/CollisionShape2D.disabled = false
	position = pos
	if not $bomb_plant_timer.is_stopped():
		$bomb_plant_timer.stop()

remotesync func bombExploded():
	bomb_planted = false
	$bomb_timer/bom_beep.stop()
	$bomb_explosion.play()
	hide()
	var explo = explosion.instance()
	explo.SCALE = 4
	explo.position = position
	explo.usr = usr
	get_tree().get_nodes_in_group("Level")[0].add_child(explo)
	explo.explode(true)

remotesync func bombDiffused():
	$bomb_timer/bom_beep.stop()
	$Timer.stop()
	hide()

remotesync func pickBomb():
	hide()
	position = Vector2(-999,-999)
	bomb_dropped = false
	
