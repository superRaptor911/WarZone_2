extends Control

func _ready():
	uploadData()

func uploadData():
	var HTTP = HTTPClient.new()
	var url = "/info.php"
	var RESPONSE = HTTP.connect_to_host("projectwarzone2.000webhostapp.com",80)
	
	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
		HTTP.poll()
		OS.delay_msec(300)
	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	var data = {name = "raptor", game = "Warzone"}
	var QUERY = to_json(data)
	var HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/json", "Content-Length: " + str(QUERY.length())]
	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	assert(RESPONSE == OK)

	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	#    # Make sure request finished
	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
