extends CanvasLayer

var parent

signal notice_closed

#show notice 
#set heading and desc with custom colors
func showNotice(par, Heading, info, h_clr = Color.white, i_clr = Color.white):
	$Notice/Header.text = Heading
	$Notice/Header.set("custom_colors/font_color",h_clr)
	$Notice/desc.text = info
	$Notice/desc.set("custom_colors/font_color",i_clr)
	
	parent = par
	parent.add_child(self)
	UiAnim.animZoomIn([$Notice])


func _on_Button_pressed():
	UiAnim.animZoomOut([$Notice])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	emit_signal("notice_closed")
	parent.remove_child(self)
