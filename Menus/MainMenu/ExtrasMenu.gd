extends CanvasLayer

func _ready():
	UiAnim.animLeftToRight([$wz, $src_code, $msgDev])
	UiAnim.animRightToLeft([$bug, $back])
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

func _on_src_code_pressed():
	OS.shell_open("https://github.com/superRaptor911/WarZone_2")

func _on_bug_pressed():
	OS.shell_open("https://github.com/superRaptor911/WarZone_2/issues")

func _on_back_pressed():
	MusicMan.click()
	UiAnim.animZoomOut([$wz, $src_code, $msgDev])
	UiAnim.animZoomOut([$bug, $back])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("mainMenu")


func _on_msgDev_pressed():
	MusicMan.click()
	UiAnim.animZoomOut([$wz, $src_code, $msgDev])
	UiAnim.animZoomOut([$bug, $back])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	MenuManager.changeScene("Extras/MsgDev")
