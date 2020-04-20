extends CanvasLayer

var btn_click
var _next_scene : String  

func _ready():
	print("ready called")
	tweenInitial()
	get_tree().paused = false
	btn_click = get_tree().root.get_node("btn_click")
	$Timer.connect("timeout",self,"goToNextScene")
	if not btn_click:
		btn_click = $btn_click
		remove_child($btn_click)
		get_tree().root.call_deferred("add_child",btn_click)


func _on_Button_pressed():
	btn_click.play()
	_next_scene = "joinMenu"
	$Timer.start()
	tweenTransition()


func _on_Button2_pressed():
	btn_click.play()
	_next_scene = "hostMenu"
	$Timer.start()
	tweenTransition()



func _on_Button3_pressed():
	btn_click.play()
	_next_scene = "settings"
	tweenTransition()
	$Timer.start()
	
func _on_store_pressed():
	btn_click.play()
	_next_scene = "storeMenu"
	tweenTransition()
	$Timer.start()
	
func _on_stats_pressed():
	btn_click.play()
	_next_scene = "stats"
	tweenTransition()
	$Timer.start()

func goToNextScene():
	MenuManager.changeScene(_next_scene)
	

#########################Tweeeening############################
func tweenTransition():
	#scale tween
	$Tween.remove_all()
	$Tween.interpolate_property($VBoxContainer,"rect_scale",$VBoxContainer.rect_scale,
		Vector2(0.1,0.1),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween position to left 
	$Tween.interpolate_property($VBoxContainer,"rect_position",$VBoxContainer.rect_position,
		$VBoxContainer.rect_position - Vector2(400,0),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func tweenInitial():
	$Tween.remove_all()
	$Tween.interpolate_property($VBoxContainer,"rect_scale",Vector2(0.1,0.1),
		$VBoxContainer.rect_scale,$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT,0.1)
	$VBoxContainer.rect_scale = Vector2(0.1,0.1)
	
	#tween position
	var new_pos = $VBoxContainer.rect_position + $VBoxContainer.rect_size / 2
	var old_pos = $VBoxContainer.rect_position
	$VBoxContainer.rect_position = new_pos
	$Tween.interpolate_property($VBoxContainer,"rect_position",new_pos,
		old_pos,$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT,0.1)
	$Tween.start()




