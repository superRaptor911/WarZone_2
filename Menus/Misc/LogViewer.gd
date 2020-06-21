extends CanvasLayer


func _ready():
	var container = $Panel/log_list/container
	var btns = container.get_children()
	var logFiles_count = Logger.getLogFilesCount()
	
	$Panel/log/Label.text = "Found %d Logs." % [logFiles_count]
	
	#hide log buttons that dont exist
	for i in btns:
		if logFiles_count <= 0:
			i.hide()
		logFiles_count -= 1
	
	UiAnim.animLeftToRight([$Panel/log_list])
	UiAnim.animRightToLeft([$Panel/log])


func _on_1_pressed_id(id):
	$Panel/log/Label.text = Logger.getLogsFromFileID(id)


func _on_back_pressed():
	MenuManager.changeScene("settings")
