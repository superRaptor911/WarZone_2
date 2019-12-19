extends "res://Objects/Monsters/Monster.gd"
var fire_ball = preload("res://Objects/Weapons/fireball.tscn")
var ready_to_attk : bool = true

func _ready():
	setSkin(game_states.modelResource.zombie_hunter.instance())
	connect("char_killed",self,"_on_hunter_killed")
	if get_tree().is_network_server():
		$vision_update.start()
		$target_update.start()

#Custom death handler 
func _on_hunter_killed():
	$bloodSpot.emitting = false
	skin.queue_free()
	skin = null
	$free_timer.start()
	
func _process(delta):
	if not get_tree().is_network_server() or not alive:
		return
	if target == null:
		return
	if not target_lost:
		at_dest = true
		attack(delta)
	else:
		if at_dest:
			set_path(target.position)
		else:
			follow_path(delta)
	rpc("_sync_position",position,rotation)

#update Target
#gets nearest target
func _on_target_update_timeout():
	_get_nearest_player()
	$target_update.start()

#update vision
#checks if target is visible or not
func _on_vision_update_timeout():
	target_lost = not _is_target_visible()
	$vision_update.start()

#Attack behaviour
#its very shity
func attack(delta : float):
	if not target.alive:
		at_dest = true
		return
	destination = target.position
	if (destination - position).length() <= attack_radius:
		if ready_to_attk:
			ready_to_attk = false
			var plasma_attack = fire_ball.instance()
			plasma_attack.create_fire_ball($hand.global_position,rotation,self)
			get_tree().root.add_child(plasma_attack)
			$attk_dl.start()
			


func _on_attk_dl_timeout():
	ready_to_attk = true
