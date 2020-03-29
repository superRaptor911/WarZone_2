extends Sprite

var bomber = null
var bomb_planted = false
var is_dropped = false

var explo = preload("res://Objects/Weapons/Bomb.tscn").instance()

signal bomb_planted
signal bomb_exploded
signal bomb_diffused

func _ready():
	hide()
	if bomber:
		bomber.connect("char_killed",self,"_on_bomber_killed")
	$Area2D/CollisionShape2D.disabled = true

func activateBomb():
	if get_tree().is_network_server():
		$bomb_plant_timer.start()


func _on_bomb_plant_timer_timeout():
	bomber.disconnect("char_killed",self,"_on_bomber_killed")
	rpc("bombPlanted",bomber.position)
	emit_signal("bomb_planted")

func _on_bomber_killed():
	dropBomb()


func dropBomb():
	rpc("bombDroped",bomber.position)


func _on_Timer_timeout():
	$bomb_timer/bom_beep.stop()
	$bomb_explosion.play()
	emit_signal("bomb_exploded")


func _on_bom_beep_timeout():
	$bomb_timer.play()
	var beep_time = 0.1 + ($Timer.time_left / $Timer.wait_time)
	$bomb_timer/bom_beep.start(beep_time)


####################Remote###########################

remotesync func bombPlanted(pos):
	$Timer.start()
	bomb_planted = true
	show()
	$bomb_timer/bom_beep.start()
	position = pos

remotesync func bombDroped(pos):
	is_dropped = true
	$Area2D/CollisionShape2D.disabled = false
	position = pos
	if not $bomb_plant_timer.is_stopped():
		$bomb_plant_timer.stop()
