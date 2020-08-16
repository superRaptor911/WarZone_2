extends PanelContainer

onready var editor = get_parent().get_parent()

onready var col_rects = [
	$tools/HBoxContainer/pen/ColorRect,
	$tools/HBoxContainer/area/ColorRect,
	$tools/HBoxContainer/rubber/ColorRect
]
 

func _on_pen_pressed():
	MusicMan.playButtonClick()
	editor.current_tool = editor.TOOLS.PEN
	hideAllRects()
	col_rects[0].show()

func _on_area_pressed():
	MusicMan.playButtonClick()
	editor.current_tool = editor.TOOLS.AREA
	hideAllRects()
	col_rects[1].show()

func _on_rubber_pressed():
	MusicMan.playButtonClick()
	editor.current_tool = editor.TOOLS.RUBBER
	hideAllRects()
	col_rects[2].show()


func hideAllRects():
	for i in col_rects:
		i.hide()
