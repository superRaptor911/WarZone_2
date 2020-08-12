extends CanvasLayer

var _next_scene : String 

var add_shown = false

func _ready():
	get_tree().set_auto_accept_quit(false)
	MenuManager.connect("back_pressed", self,"_on_back_pressed")
	Logger.Log("Game Loaded")
	add_shown = false
	if game_states.game_settings.music_enabled and not MusicMan.music_player.playing:
		MusicMan.music_player.play()
		
	UiAnim.animLeftToRight([$VBoxContainer])
	get_tree().paused = false
	$Timer.connect("timeout",self,"goToNextScene")
	$g_version.text = "V " + String(game_states.current_game_version)


func _on_Button2_pressed():
	MusicMan.click()
	_next_scene = "newGame"
	$Timer.start()
	tweenTransition()

func _on_Button3_pressed():
	MusicMan.click()
	_next_scene = "settings"
	tweenTransition()
	$Timer.start()
	
func _on_store_pressed():
	MusicMan.click()
	_next_scene = "storeMenu"
	tweenTransition()
	$Timer.start()
	
func _on_stats_pressed():
	MusicMan.click()
	_next_scene = "stats"
	tweenTransition()
	$Timer.start()

func goToNextScene():
	MenuManager.changeScene(_next_scene)


func _on_back_pressed():
	get_tree().quit(0)

#########################Tweeeening############################
func tweenTransition():
	#admob.hide_banner()
	#scale tween
	$Tween.remove_all()
	$Tween.interpolate_property($VBoxContainer,"rect_scale",$VBoxContainer.rect_scale,
		Vector2(0.1,0.1),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween position to left 
	$Tween.interpolate_property($VBoxContainer,"rect_position",$VBoxContainer.rect_position,
		$VBoxContainer.rect_position - Vector2(400,0),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()


func _on_extras_pressed():
	MusicMan.click()
	MenuManager.changeScene("extras")
