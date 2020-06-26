extends Node

var file : File = File.new()
var file_name = ""
var logs = Array()
var notice = preload("res://Objects/Misc/Notice.tscn").instance()
var max_logs = 8

var print_to_console = true

var path = "user://"
var final_path = path + "logs/"


func _ready():
	var dir = Directory.new()
	dir.open(path)
	dir.make_dir("logs")
	var log_index = -1
	
	for i in range(max_logs):
		if not file.file_exists(final_path + String(i) + ".txt"):
			log_index = i
			break
	
	if not game_states.game_settings.enable_logging:
		return
		
	#reached max log files , delete them
	if log_index == -1:
		for i in range(16):
			dir.remove(final_path + String(i) + ".txt")
		log_index = 0

	file_name = final_path + String(log_index) + ".txt"
	Log("Created log file %s" % [file_name])

	var timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 1
	add_child(timer)
	timer.connect("timeout", self, "saveLogs")
	timer.start()



func Log(msg : String, instant_save = false):
	if game_states.game_settings.enable_logging:
		var dt = OS.get_datetime()
		var message : String = ("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second]) + msg
		logs.append(message)
	
		if print_to_console:
			print(message)
	
		if instant_save:
			saveLogs()


func LogError(func_name : String, msg : String):
	if game_states.game_settings.enable_logging:
		var dt = OS.get_datetime()
		var message : String = ("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second])
		message += "Error at func %s" % [func_name]
		logs.append(message)
		logs.append("-----> %s" % [msg])
		saveLogs()
		
		if print_to_console:
			print(message)
			print("-----> %s" % [msg])


func saveLogs():
	if not logs.empty():
		#
		if file.file_exists(file_name):
			file.open(file_name,File.READ_WRITE)
			file.seek_end()
		else:
			file.open(file_name,File.WRITE)
			

		for i in logs:
			file.store_line(i)
		file.close()
		logs.clear()


func getLogFilesCount() -> int:
	var count = 0
	for i in range(max_logs):
		if not file.file_exists(final_path + String(i) + ".txt"):
			break
		count += 1
	
	return count
	

func getLogsFromFileID(id : int) -> String:
	var log_data : String
	var fpath = final_path + String(id) + ".txt"
	
	if file.file_exists(fpath):
		file.open(fpath, file.READ)
		log_data = file.get_as_text()
		file.close()

	
	return log_data
