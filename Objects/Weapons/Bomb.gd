extends Node2D
export var damage : float = 100
var usr



func explode():
	$AnimationPlayer.play("explode")
	$Tween.interpolate_property($Sprite,"scale",Vector2(1,1),Vector2(2,2),1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	if $Particles2D:
		$Particles2D.emitting = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		var chars = get_tree().get_nodes_in_group("Actor")
		for c in chars:
			c.takeDamage(damage,self,usr)
		queue_free()
