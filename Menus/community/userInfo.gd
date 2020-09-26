extends Control


func _ready():
	$Panel/name.text = game_states.player_info.name
	$Panel/bio_label.text = game_states.player_data.desc


func _on_update_pressed():
	var user_data = {}
	user_data['id'] = OS.get_unique_id()
	user_data['name'] = $Panel/name.text
	user_data['bio'] = $Panel/bio.text
	
	# Update Locally
	game_states.player_data.desc = user_data['bio']
	game_states.player_data.name = user_data['name']
	game_states.player_info.name = user_data['name']
	game_states.savePlayerData()
	
	# Update in server
	showDownloadingLabel()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var uploader = DataUploader.new()
	uploader.connect("connection_failed", self, "on_upload_failed")
	uploader.connect("upload_failed", self , "on_upload_failed")
	uploader.connect("upload_finished", self, "on_upload_finished")
	uploader.uploadData(user_data, "userDataReceiver.php")


func on_upload_failed():
	$upStatus/Label.text = "Failed!"
	yield(get_tree().create_timer(1.5), "timeout")
	$upStatus.hide()

func on_upload_finished():
	$upStatus/Label.text = "Done!"
	yield(get_tree().create_timer(1.5), "timeout")
	$upStatus.hide()
	game_states.player_data.name = $Panel/name.text
	game_states.savePlayerData()

func showDownloadingLabel():
	$upStatus.show()
	$upStatus/Label.text = "Uploading . . ."
