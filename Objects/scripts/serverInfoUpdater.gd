extends Node

var timer = Timer.new()
var thread = Thread.new()

func _ready():
	timer.wait_time = 90
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	thread.start(self, "uploadServerInfo")


func _on_timer_timeout():
	thread.start(self, "uploadServerInfo")


func uploadServerInfo(_msg):
	var uploader = DataUploader.new()
	uploader.connect("connection_failed", self, "update_failed")
	uploader.connect("upload_failed", self, "update_failed")
	uploader.connect("upload_finished", self, "updated_ServerInfo")
	uploader.uploadData(game_server.serverInfo, "serverInfoReceiver.php")


func updated_ServerInfo():
	thread.wait_to_finish()

func update_failed():
	print("Update Failed")
	thread.wait_to_finish()

func _exit_tree():
	thread.wait_to_finish()
