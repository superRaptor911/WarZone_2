extends "res://Objects/Monsters/Monster.gd"
var fire_ball = preload("res://Objects/Weapons/fireball.tscn")
var ready_to_attk : bool = true

func _ready():
	setSkin(game_states.modelResource.zombie_hunter.instance())
	connect("char_killed",self,"_on_hunter_killed")
	if get_tree().is_network_server():
		add_child(load("res://Objects/custom_scripts/necron_fsm.gd").new())

#Custom death handler 
func _on_hunter_killed():
	$bloodSpot.emitting = false
	$free_timer.start()

#Attack behaviour
#its very shity
func attack(delta : float):
	destination = target.position
	if ready_to_attk:
		ready_to_attk = false
		var plasma_attack = fire_ball.instance()
		plasma_attack.create_fire_ball($hand.global_position,rotation,self)
		get_tree().root.add_child(plasma_attack)
		rpc("_create_fire_ball")
		$attk_dl.start()


remote func _create_fire_ball():
	var plasma_attack = fire_ball.instance()
	plasma_attack.create_fire_ball($hand.global_position,rotation,self)
	get_tree().root.add_child(plasma_attack)


func _on_attk_dl_timeout():
	ready_to_attk = true
