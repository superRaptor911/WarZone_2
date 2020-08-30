extends Sprite


onready var tween = $Tween

func _ready():
	tween.interpolate_property(self, "position", position, position + 
		Vector2(rand_range(-64,64),rand_range(-16,16)), 1,
		Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(self, "scale", Vector2.ONE, Vector2(0.5,0.5),
		0.3,Tween.TRANS_EXPO,Tween.EASE_IN)
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0),
		1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,3)
	tween.start()
	$Timer.start()


func _on_Timer_timeout():
	queue_free()
