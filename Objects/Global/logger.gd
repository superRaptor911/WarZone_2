extends Node

var file : File = File.new()
var file_name = "user://logs.txt"
var logs = Array()
var notice = preload("res://Objects/Misc/Notice.tscn").instance()
var max_logs = 8

var print_to_console = true
var output_to_file = true
var console_msg = ""


signal got_new_msg(msg)


func _ready():
	if not game_states.game_settings.enable_logging:
		return
	Log("Created log file %s" % [file_name])



func Log(msg : String, instant_save = false):
	if game_states.game_settings.enable_logging:
		var dt = OS.get_datetime()
		var message : String = ("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second]) + msg
		logs.append(message)
		
		if print_to_console:
			print(message)
	
		if logs.size() > 50 or instant_save:
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
	if not logs.empty() and output_to_file:
		if file.file_exists(file_name):
			file.open(file_name,File.READ_WRITE)
		else:
			file.open(file_name,File.WRITE)
		for i in logs:
			file.store_line(i)
		file.close()



remote func remoteMsg(msg : String):
	emit_signal("got_new_msg", msg)
