extends Node2D


func _ready():
	var tween =$Tween
	tween.interpolate_property(self,"scale", Vector2(0,0), Vector2(1,1), 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self,"modulate", Color(1,1,1,1), Color(1,1,1,0), 2,
		Tween.TRANS_LINEAR, Tween.EASE_OUT, 8)
	tween.start()
	$Timer.start()


func _on_Timer_timeout():
	queue_free()
