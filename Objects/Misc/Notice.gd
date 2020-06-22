extends Panel

var parent

func _ready():
	show()

#show notice 
#set heading and desc with custom colors
func showNotice(par, Heading, info, h_clr = Color.white, i_clr = Color.white):
	show()
	$Header.text = Heading
	$Header.set("custom_colors/font_color",h_clr)
	$desc.text = info
	$desc.set("custom_colors/font_color",i_clr)
	
	parent = par
	parent.add_child(self)
	UiAnim.animZoomIn([self])


func _on_Button_pressed():
	UiAnim.animZoomOut([self])
	yield(get_tree().create_timer(0.5 * UiAnim.anim_scale), "timeout")
	parent.remove_child(self)
