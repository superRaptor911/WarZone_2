extends Node
class_name DataUploader

signal connection_successful
signal connection_failed

signal upload_finished
signal upload_failed

var one_time_use = true

func _init(one_time = true):
	one_time_use = one_time


func uploadData(data : Dictionary, php_file : String):
	var HTTP = HTTPClient.new()
	var url = "/" + php_file
	var RESPONSE = HTTP.connect_to_host("projectwarzone2.000webhostapp.com",80)
	
	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
		HTTP.poll()
		OS.delay_msec(300)
	
	if HTTP.get_status() == HTTPClient.STATUS_CONNECTED:
		emit_signal("connection_successful")
	else:
		emit_signal("connection_failed")
		if one_time_use:
			queue_free()
		return
	
	var QUERY = to_json(data)
	var HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/json", "Content-Length: " + str(QUERY.length())]
	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	
	if RESPONSE != OK:
		emit_signal("upload_failed")
		if one_time_use:
			queue_free()
		return

	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	
	if HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED:
		emit_signal("upload_finished")
	else:
		emit_signal("upload_failed")
	
	if one_time_use:
		queue_free()
