extends "res://Objects/Monsters/Monster.gd"
class_name Necron


var last_state : bool = false

func _ready():
	setSkin(game_states.modelResource.zombie_model.instance())
	connect("char_killed",self,"_on_necron_killed")
	if get_tree().is_network_server():
		add_child(load("res://Objects/custom_scripts/necron_fsm.gd").new())
		#$vision_update.start()
		#$target_update.start()
	
func _on_necron_killed():
	$bloodSpot.emitting = false
	#skin.queue_free()
	#skin = null
	$free_timer.start()

func attack(delta : float):
	if (destination - position).length() <= attack_radius:
		target.takeDamage(damage * delta,null,self)


