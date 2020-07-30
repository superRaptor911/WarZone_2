#This singleton is an utility to manage UI animation
#It only supports "Control" class 
extends Node

var tween = Tween.new()
var anim_scale = 1.0 setget setAnimScale
const half_res = Vector2(640, 360)


func _ready():
	add_child(tween)
	Logger.Log("Setting up animation utility")

func setAnimScale(val):
	anim_scale = max(1, min(10, val))


#Left to right animation
func animLeftToRight(elements : Array, duration = 0.5, method = Tween.TRANS_QUAD , delay = 0.0):
	duration *= anim_scale
	delay *= anim_scale

	for i in elements:
		i.rect_pivot_offset = Vector2.ZERO
		var ipos = Vector2(i.rect_position.x - half_res.x - i.rect_size.x ,i.rect_position.y)
		tween.interpolate_property(i, "rect_position", ipos, i.rect_position,
			duration, method, Tween.EASE_OUT, delay)
		i.rect_position = ipos
	
	tween.start()


#Right to Left animation
func animRightToLeft(elements : Array, duration = 0.5, method = Tween.TRANS_QUAD , delay = 0.0):
	duration *= anim_scale
	delay *= anim_scale

	for i in elements:
		i.rect_pivot_offset = Vector2.ZERO
		var ipos = Vector2(i.rect_position.x + half_res.x ,i.rect_position.y)
		tween.interpolate_property(i, "rect_position", ipos, i.rect_position,
			duration, method, Tween.EASE_OUT, delay)
		i.rect_position = ipos
	
	tween.start()


func animTopToBottom(elements : Array, duration = 0.5, method = Tween.TRANS_QUAD , delay = 0.0):
	duration *= anim_scale
	delay *= anim_scale

	for i in elements:
		i.rect_pivot_offset = Vector2.ZERO
		var ipos = Vector2(i.rect_position.x, i.rect_position.y - half_res.y - i.rect_size.y)
		tween.interpolate_property(i, "rect_position", ipos, i.rect_position,
			duration, method, Tween.EASE_OUT, delay)
		i.rect_position = ipos
	
	tween.start()


func animZoomOut(elements : Array, duration = 0.5, method = Tween.TRANS_QUAD , delay = 0.0):
	duration *= anim_scale
	delay *= anim_scale

	for i in elements:
		i.rect_pivot_offset = i.rect_size / 2
		tween.interpolate_property(i, "rect_scale", Vector2(1,1), Vector2(0,0),
			duration, method, Tween.EASE_OUT, delay)
		i.rect_scale = Vector2(1,1)
	
	tween.start()


func animZoomIn(elements : Array, duration = 0.5, method = Tween.TRANS_QUAD , delay = 0.0):
	duration *= anim_scale
	delay *= anim_scale

	for i in elements:
		i.rect_pivot_offset = i.rect_size / 2
		tween.interpolate_property(i, "rect_scale", Vector2.ZERO, Vector2(1,1),
			duration, method, Tween.EASE_OUT, delay)
		i.rect_scale = Vector2.ZERO
	
	tween.start()

func getAnimDuration() -> float:
	return 0.5 * anim_scale
