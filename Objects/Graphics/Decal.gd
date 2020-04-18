extends Sprite


export var stay_time = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	print("decal")
	$Timer.wait_time = stay_time
	$Timer.start()



func _on_Timer_timeout():
	$Tween.interpolate_property(self,"modulate",Color8(255,255,255,255),
	Color8(255,255,255,0),2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	queue_free()
