extends Node
class_name DataUploader

signal connection_successful
signal connection_failed

signal upload_finished
signal upload_failed

signal download_finished
signal download_failed

var one_time_use = true

#const host_site = "projectwarzone2.000webhostapp.com"
#const host_site = "127.0.0.1"
const host_site = "35.239.53.71"

func _init(one_time = true):
	one_time_use = one_time


func uploadData(data : Dictionary, php_file : String, host = ""):
	var HTTP = HTTPClient.new()
	var url = "/" + php_file
	
	if host == "":
		host = host_site
	
	var RESPONSE = HTTP.connect_to_host(host, 80)
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


func getData(php_file : String, query : Dictionary = {a = "a"} , host = ""):
	var dict = {}
	var HTTP = HTTPClient.new()
	var url = "/" + php_file
	
	if host == "":
		host = host_site
	
	var RESPONSE = HTTP.connect_to_host(host, 80)
	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
		HTTP.poll()
		OS.delay_msec(300)
	
	if HTTP.get_status() == HTTPClient.STATUS_CONNECTED:
		print("connection pass")
		emit_signal("connection_successful")
	else:
		emit_signal("connection_failed")
		if one_time_use:
			queue_free()
		return null
	
	var QUERY = to_json(query)
	var HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/json", "Content-Length: " + str(QUERY.length())]
	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	
	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	
	if HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED:
		print("upload fin")
		emit_signal("upload_finished")
	else:
		emit_signal("upload_failed")

	if HTTP.has_response():

		if HTTP.is_response_chunked():
			print("Response is Chunked!")
		else:
			var bl = HTTP.get_response_body_length()
			print("Response Length: ", bl)

		var rb = PoolByteArray() # Array that will hold the data.

		while HTTP.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			HTTP.poll()
			var chunk = HTTP.read_response_body_chunk() # Get a chunk.
			if chunk.size() == 0:
				# Got nothing, wait for buffers to fill a bit.
				OS.delay_usec(500)
			else:
				rb = rb + chunk # Append to read buffer.

		dict = parse_json(rb.get_string_from_ascii())
	else:
		emit_signal("download_failed")
		return null
	
	if dict == null:
		emit_signal("download_failed")
	else:
		emit_signal("download_finished")
	
	return dict
