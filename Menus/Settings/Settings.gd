extends CanvasLayer


func _ready():
	
	#$Admob.load_banner()
	#UiAnim.animLeftToRight([$TabContainer])
	MenuManager.connect("back_pressed", self,"_on_Button_pressed")
	MenuManager.admob.show_interstitial()

func _on_Button_pressed():
	MusicMan.click()
	#game_states.saveSettings()
	#UiAnim.animZoomOut([$TabContainer])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("mainMenu")



func _on_display_pressed():
	MusicMan.click()
	MenuManager.changeScene("settings/display")


func _on_sound_pressed():
	pass # Replace with function body.


func _on_contols_pressed():
	MusicMan.click()
	MenuManager.changeScene("settings/control")


func _on_view_logs_pressed():
	MenuManager.changeScene("settings/viewLogs")
