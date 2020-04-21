extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	initialTween()


func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("mainMenu")


func _on_bw_pressed():
	MusicMan.click()
	MenuManager.changeScene("SM/gunStore")


func _on_sw_pressed():
	MusicMan.click()
	MenuManager.changeScene("SM/gunSelection")


func _on_bs_pressed():
	MusicMan.click()
	MenuManager.changeScene("SM/skinBuy")


func _on_ss_pressed():
	MusicMan.click()
	MenuManager.changeScene("SM/skinSelect")


####################Tweeening###########################

func initialTween():
	var duration = 0.5
	var node = $Panel
	node.rect_pivot_offset = node.rect_size / 2
	node.rect_scale = Vector2(0.01,0.01)
	$Tween.interpolate_property(node,"rect_scale",node.rect_scale,
		Vector2(1,1),duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()








