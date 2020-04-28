extends PopupPanel


#show notice 
#set heading and desc with custom colors
func showNotice(Heading,info, h_clr = Color.white, i_clr = Color.white):
	$Header.text = Heading
	$Header.set("custom_colors/font_color",h_clr)
	$desc.text = info
	$desc.set("custom_colors/font_color",i_clr)
	show()
