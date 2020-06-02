extends CanvasLayer

var _next_scene : String 
onready var admob = $Admob
var add_shown = false

func _ready():
	Logger.Log("Game Loaded")
	add_shown = false
	MusicMan.music_player.volume_db = -2.0
	if game_states.game_settings.music_enabled and not MusicMan.music_player.playing:
		MusicMan.music_player.play()
		
	UiAnim.animLeftToRight([$VBoxContainer])
	get_tree().paused = false
	$Timer.connect("timeout",self,"goToNextScene")
	admob.load_banner()
	admob.load_interstitial()


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
	

#########################Tweeeening############################
func tweenTransition():
	admob.hide_banner()
	#scale tween
	$Tween.remove_all()
	$Tween.interpolate_property($VBoxContainer,"rect_scale",$VBoxContainer.rect_scale,
		Vector2(0.1,0.1),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween position to left 
	$Tween.interpolate_property($VBoxContainer,"rect_position",$VBoxContainer.rect_position,
		$VBoxContainer.rect_position - Vector2(400,0),$Timer.wait_time,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()




func _on_Admob_interstitial_loaded():
	if randi() % 100 < 40 and (not add_shown):
		admob.show_interstitial()
		add_shown = true


func _on_Admob_banner_loaded():
	admob.show_banner()
