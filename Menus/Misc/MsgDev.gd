extends Control

var screen_height = ProjectSettings.get_setting("display/window/size/height")

var data = {
	id = "",
	name = "",
	subject = "",
	message = ""
}


func _ready():
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func _on_name_text_entered(_new_text):
	print("pressed")
	OS.hide_virtual_keyboard()


func _on_subject_text_entered(_new_text):
	OS.hide_virtual_keyboard()



func _on_send_pressed():
	if $PanelContainer/Panel/name.text == "":
		var notice = Notice.new()
		notice.showNotice(self, "Error", "Please fill your name.", Color.red)
		return

	if $PanelContainer/Panel/subject.text == "":
		var notice = Notice.new()
		notice.showNotice(self, "Error", "Please fill subject.", Color.red)
		return
	
	data.id = String(OS.get_unique_id())
	data.name = $PanelContainer/Panel/name.text
	data.subject = $PanelContainer/Panel/subject.text
	data.message = $PanelContainer/Panel/message.text
	
	$PanelContainer.hide()
	$status.show()
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	var uploader = DataUploader.new()
	uploader.connect("connection_successful",self, "on_connected")
	uploader.connect("connection_failed", self, "on_connection_failed")
	uploader.connect("upload_finished", self, "on_uploaded")
	uploader.connect("connection_failed", self, "on_upload_failed")
	
	uploader.uploadData(data, "message.php")


func on_connected():
	$status/Panel/Label.text = "Uploading ..."

func on_connection_failed():
	$status/Panel/Label.text = "Unable to connect server."
	yield(get_tree().create_timer(1), "timeout")

func on_uploaded():
	$status/Panel/Label.text = "Message sent {-_-}"
	yield(get_tree().create_timer(1), "timeout")
	_on_back_pressed()

func on_upload_failed():
	$status/Panel/Label.text = "Message not sent"
	yield(get_tree().create_timer(1), "timeout")
	_on_back_pressed()

func _on_back_pressed():
	MusicMan.click()
	MenuManager.changeScene("extras")


func _on_name_text_changed(new_text):
	print(new_text)

onready var label = $Label

func _on_message_text_changed():
	label.show()
	label.rect_size.y = OS.window_size.y - OS.get_virtual_keyboard_height()
	label.get_node("Label").text = $PanelContainer/Panel/message.text


func _process(_delta):
	if OS.get_virtual_keyboard_height() <= 0:
		label.hide()
