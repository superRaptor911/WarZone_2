extends CanvasLayer

func _ready():
	UiAnim.animLeftToRight([$wz, $src_code, $msgDev])
	UiAnim.animRightToLeft([$attrib, $back])
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_src_code_pressed():
	OS.shell_open("https://github.com/superRaptor911/WarZone_2")


func _on_back_pressed():
	MusicMan.click()
	UiAnim.animZoomOut([$wz, $src_code, $msgDev])
	UiAnim.animZoomOut([$attrib, $back])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("mainMenu")


func _on_msgDev_pressed():
	MusicMan.click()
	UiAnim.animZoomOut([$wz, $src_code, $msgDev])
	UiAnim.animZoomOut([$attrib, $back])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("Extras/MsgDev")


func _on_rate_pressed():
	OS.shell_open("https://play.google.com/store/apps/details?id=com.raptor.inc")


func _on_attrib_pressed():
	MusicMan.click()
	UiAnim.animZoomOut([$wz, $src_code, $msgDev])
	UiAnim.animZoomOut([$attrib, $back])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("Extras/Attrib")
