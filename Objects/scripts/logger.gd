extends Node

var file : File = File.new()
var file_name = ""
var logs = Array()

func _ready():
	var dir = Directory.new()
	dir .open("res://")
	dir.make_dir("logs")
	var log_index = -1
	
	for i in range(16):
		if not file.file_exists("res://logs/" + String(i) + ".txt"):
			log_index = i
			break
	
	#reached max log files , delete them
	if log_index == -1:
		for i in range(16):
			dir.remove("res://logs/" + String(i) + ".txt")
		log_index = 0

	file_name = "res://logs/" + String(log_index) + ".txt"
	Log("Created log file %s" % [file_name])

	var timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 1
	add_child(timer)
	timer.connect("timeout", self, "saveLogs")
	timer.start()



func Log(msg, instant_save = false) -> bool:
	var dt = OS.get_datetime()
	var message : String = ("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second]) + msg
	logs.append(message)

	if instant_save:
		saveLogs()
	return true


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
