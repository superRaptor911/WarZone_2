extends "res://Objects/Bots/Zombie.gd"

export var ranged_atk_damage = 60
export var ranged_atk_range = 200
export var ranged_attack_name = "spit"

onready var attk_sfx = $zAttack
onready var squiq_sfx = $squid

func _ready():
	$squid/playback_timer.wait_time = rand_range(8, 15)
	$squid/playback_timer.start()

func _on_navTimer_timeout():
	getTarget()
	var T = game_server._unit_data_list.get(target_id)
	if T:
		target_visible = isTargetVisible(T.ref)
		if target_visible:
			var dist = (T.ref.position - position).length()
			if dist < ranged_atk_range:
				rpc("rangedAttack")
				T.ref.takeDamage(ranged_atk_damage, ranged_attack_name, "SCP-682")

remotesync func rangedAttack():
	attk_sfx.play()
	model.rangedAttack()


func _on_playback_timer_timeout():
	squiq_sfx.play()
