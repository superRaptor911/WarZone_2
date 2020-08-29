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
const host_site = "127.0.0.1"
#const host_site = "35.239.53.71"

func _init(one_time = true):
	one_time_use = one_time


func uploadData(data : Dictionary, php_file : String, host = "") ->bool:
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
		return false
	
	var QUERY = to_json(data)
	var HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/json", "Content-Length: " + str(QUERY.length())]
	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	
	if RESPONSE != OK:
		emit_signal("upload_failed")
		if one_time_use:
			queue_free()
		return false

	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	
	if HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED:
		emit_signal("upload_finished")
	else:
		emit_signal("upload_failed")
	
	if one_time_use:
		queue_free()
	return true


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
	
	if RESPONSE != OK:
		emit_signal("connection_failed")
		if one_time_use:
			queue_free()
		return
	
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


func uploadFile(file_path : String, php_file : String, filename = ""):
	var file = File.new()
	file.open(file_path, File.READ)
	var file_content = file.get_buffer(file.get_len())
	file.close()
	
	if filename == "":
		filename = file_path.get_basename()
	
	var body = PoolByteArray()
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L\r\n".to_utf8())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"" + filename +"\"\r\n").to_utf8())
	body.append_array("Content-Type: application/octet-stream\r\n\r\n".to_utf8())
	body.append_array(file_content)
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L--\r\n".to_utf8())

	var headers = [
		"Content-Type: multipart/form-data;boundary=\"WebKitFormBoundaryePkpFF7tjBAqx29L\""
	]
	var http = HTTPClient.new()
	http.connect_to_host(host_site, 80, false)

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(500)

	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		print("connection pass")
		emit_signal("connection_successful")
	else:
		emit_signal("connection_failed")
		if one_time_use:
			queue_free()
		return null

	var err = http.request_raw(HTTPClient.METHOD_POST, "/"+php_file , headers, body)

	if err != OK:
		emit_signal("upload_failed")
		if one_time_use:
			queue_free()
		return

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		if not OS.has_feature("web"):
			OS.delay_msec(500)
		else:
			yield(Engine.get_main_loop(), "idle_frame")

	if http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED:
		emit_signal("upload_finished")
	else:
		emit_signal("upload_failed")
	

	if one_time_use:
		queue_free()

