extends Area2D
export var damage : float = 30
export var speed : float = 200

var sender

#play fire spwaning animation
func _ready():
	$AnimationPlayer.play("fire_beg")


func _on_AnimationPlayer_animation_finished(anim_name):
	#play on air animation
	if anim_name == "fire_beg":
		$AnimationPlayer.play("firebal")
	#play flame out animation
	elif anim_name == "fire_end":
		queue_free()

func _process(delta):
	position += speed * transform.x * delta

#set pos rot and sender while creating
func create_fire_ball(pos,rot,sen):
	position = pos
	rotation = rot - 1.57
	sender = sen
	

func _on_fireball_body_entered(body):
	if body.is_in_group("Actor"):
		body.takeDamage(damage,self,sender)
	speed = 0
	$AnimationPlayer.play("fire_end")
