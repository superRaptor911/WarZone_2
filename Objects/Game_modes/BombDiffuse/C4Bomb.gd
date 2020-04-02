extends Sprite

var bomber = null
var bomb_planted = false
var explo = preload("res://Objects/Weapons/Bomb.tscn").instance()

var diffuser = null

signal bomb_planted
signal bomb_exploded
signal bomb_diffused

signal bomb_diffuser
signal bomb_diffuser_left

func _ready():
	hide()
	$Area2D/CollisionShape2D.disabled = true

func setBomber(b):
	bomber = b

func activateBomb():
	if get_tree().is_network_server():
		bomb_planted = true
		rpc("bombPlanted",bomber.position)
		emit_signal("bomb_planted")

func diffuseBomb():
	bomb_planted = false
	$bomb_timer/bom_beep.stop()
	$Timer.stop()
	hide()
	emit_signal("bomb_diffused")
	diffuser = null

func dropBomb():
	rpc("bombDroped",bomber.position)

func resetBomb():
	rpc("_resetBomb")

func _on_Timer_timeout():
	rpc("bombExploded")
	emit_signal("bomb_exploded")


func _on_bom_beep_timeout():
	$bomb_timer.play()
	var beep_time = 0.1 + ($Timer.time_left / $Timer.wait_time)
	$bomb_timer/bom_beep.start(beep_time)


func _on_Area2D_body_entered(body):
	if bomb_planted and (not diffuser) and body.is_in_group("Unit") and body.team.team_id == 1:
		diffuser = body
		emit_signal("bomb_diffuser")


func _on_Area2D_body_exited(body):
	if bomb_planted and (body == diffuser):
		emit_signal("bomb_diffuser_left")
		diffuser = null

####################Remote###########################

remotesync func bombPlanted(pos):
	$Timer.start()
	show()
	$bomb_timer/bom_beep.start()
	position = pos

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

remotesync func _resetBomb():
	bomber = null
	diffuser = null
	bomb_planted = false
	$bomb_timer/bom_beep.stop()
	$Timer.stop()
	hide()
