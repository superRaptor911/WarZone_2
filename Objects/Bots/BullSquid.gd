extends "res://Objects/Bots/Zombie.gd"

var custom_model = preload("res://Objects/Models/bull_sqid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Override previous func defined in zombie.gd
func P_on_killed():
	$body.show()
	$dtween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 6)
	$dtween.start()

func _on_navTimer_timeout():
	getTarget()
	var T = game_server._unit_data_list.get(target_id)
	if T:
		target_visible = isTargetVisible(T.ref)
		if target_visible:
			var dist = (T.ref.position - position).length()
			if dist < 200:
				if dist < 100:
					rpc("zmAttack")
				else:
					rpc("acidAttack")
					T.ref.takeDamage(melee_damage, "acid", "Zombie")

remotesync func acidAttack():
	model.spitAcid()
