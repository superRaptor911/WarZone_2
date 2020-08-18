extends CanvasLayer
class_name Notice

var parent
var one_time_use = false

var timer = Timer.new()
var panel = preload("res://Objects/Misc/NoticePanel.tscn").instance()

signal notice_closed


func _init(once : bool = true):
	one_time_use = once

func _ready():
	add_child(panel)
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	panel.get_node("Button").connect("pressed", self, "_on_Button_pressed")

#show notice 
#set heading and desc with custom colors
func showNotice(par, Heading, info, h_clr = Color.white, i_clr = Color.white):
	panel.get_node("Header").text = Heading
	panel.get_node("Header").set("custom_colors/font_color",h_clr)
	panel.get_node("desc").text = info
	panel.get_node("desc").set("custom_colors/font_color",i_clr)
	
	parent = par
	parent.add_child(self)
	UiAnim.animZoomIn([panel])


func _on_Button_pressed():
	UiAnim.animZoomOut([panel])
	timer.start(UiAnim.getAnimDuration())


func _on_timer_timeout():
	emit_signal("notice_closed")
	if one_time_use:
		queue_free()
	else:
		parent.remove_child(self)
