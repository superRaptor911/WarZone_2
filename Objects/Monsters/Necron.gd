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
	$free_timer.start(8)

func attack(delta : float):
	if (destination - position).length() <= attack_radius and $Timer.is_stopped():
		target.takeDamage(damage,null,self)
		$Timer.start()
		skin.get_node("anim").play("zombie_attack")
		skin.current_anim = "zm_attk"


