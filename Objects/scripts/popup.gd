extends Control


var timer = Timer.new()
var tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	timer.one_shot = true
	timer.wait_time = 2.5
	timer.connect("timeout",self,"_on_timeout")
	add_child(timer)
	add_child(tween)


func popup(sec):
	timer.start(sec)
	show()
	self.rect_scale = Vector2(0,0)
	tween.interpolate_property(self,"rect_scale",Vector2(0,0),Vector2(1,1),
		0.7,Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.start()

func _on_timeout():
	tween.interpolate_property(self,"modulate",Color8(255,255,255,255),
		Color8(255,255,255,0),0.7,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(self,"visible",true,false,0.1,Tween.TRANS_LINEAR,Tween.EASE_IN,0.75)
	tween.start()
