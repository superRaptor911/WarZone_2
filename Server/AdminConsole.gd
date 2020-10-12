extends Control

onready var output_box = $input/output
onready var input_box = $input

var history = PoolStringArray()
var cur_history_id = 0

# Function configuration
var config = {
	serverInfo = {
		ref = self, fun = "getServerInfo", is_remote = false, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Get Server config dictionary"
	},
	
	clear = {
		ref = self, fun = "clearOutputBox", is_remote = false, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Clears the console"
	},
	
	exit = {
		ref = self, fun = "exitConsole", is_remote = false, min_arg = 0, max_arg = 1, 
		args_types = ['i'], help = "Exit terminal"
	},
	
	echo = {
		ref = self, fun = "consoleResponse", is_remote = false, min_arg = 0, max_arg = 1, 
		args_types = ['s'], help = "output text to terminal"
	},
	
	changeLevel = {
		ref = game_server, fun = "S_changeLevelTo", is_remote = true, min_arg = 2, max_arg = 2, 
		args_types = ['s', 's'], help = "Change level and game mode"
	},
	
	listLevels = {
		ref = game_server, fun = "S_getAvailableMaps", is_remote = true, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Lists available levels"
	},
	
	bot_count = {
		ref = game_server, fun = "S_getBotCount", is_remote = true, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Number of bots in server"
	},
	
	player_count = {
		ref = game_server, fun = "S_getPlayerCount", is_remote = true, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Number of players in server"
	},
	
	help = {
		ref = self, fun = "showHelp", is_remote = false, min_arg = 0, max_arg = 0, 
		args_types = [], help = "Shows help"
	},
}


# Connect Response signals
func _ready():
	Logger.connect("got_new_msg", self, "consoleResponse")



# Parse input
func _on_input_text_entered(new_text : String):
	if new_text == "":
		return
	input_box.clear()
	history.append(new_text)
	cur_history_id = history.size() - 1
	var strings = splitArgs(new_text)
	if strings.empty():
		return
	
	if not config.has(strings[0]):
		consoleResponse("%s not found" % [strings[0]])
		return
	
	var func_inf = config[strings[0]]
	
	var args_count = strings.size() - 1
	if args_count > func_inf.max_arg:
		consoleResponse("%s called with %d argument(s), max allowed %d" % [strings[0], args_count, func_inf.max_arg])
		return
	if args_count < func_inf.min_arg:
		consoleResponse("%s requires atleast %d argument(s) but called with %d" % [strings[0], func_inf.min_arg, args_count])
		return
	
	# Reformat arguments with correct types
	var args = []
	for i in range(args_count):
		if func_inf.args_types[i] == 's':
			args.append(strings[i+1])
		if func_inf.args_types[i] == 'i':
			args.append(int(strings[i+1]))
		if func_inf.args_types[i] == 'f':
			args.append(float(strings[i+1]))
		if func_inf.args_types[i] == 'b':
			args.append(bool(strings[i+1]))
	
	if not func_inf.is_remote:
		if args_count == 0:
			func_inf.ref.call(func_inf.fun)
		elif args_count == 1:
			func_inf.ref.call(func_inf.fun, args[0])
		elif args_count == 2:
			func_inf.ref.call(func_inf.fun, args[0], args[1])
		elif args_count == 3:
			func_inf.ref.call(func_inf.fun, args[0], args[1], args[2])
	else:
		if args_count == 0:
			func_inf.ref.rpc_id(1, func_inf.fun)
		elif args_count == 1:
			func_inf.ref.rpc_id(1, func_inf.fun, args[0])
		elif args_count == 2:
			func_inf.ref.rpc_id(1, func_inf.fun, args[0], args[1])
		elif args_count == 3:
			func_inf.ref.rpc_id(1, func_inf.fun, args[0], args[1], args[2])


func splitArgs(text : String, del = ' ') -> Array:
	var arr = Array()
	var quotes_enabled  = false
	var string : String = ""
	for i in text:
		if i == '"' or i == "'":
			quotes_enabled = not quotes_enabled
			continue
		if i == del and not quotes_enabled:
			if string != "":
				arr.append(string)
				string = ""
			continue
		
		string += i
	
	if string != "":
		arr.append(string)
	
	return arr


func consoleResponse(msg):
	output_box.text += msg + "\n"


func _on_input_gui_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_UP:
			if not history.empty():
				input_box.text = history[cur_history_id]
				input_box.caret_position = input_box.text.length()
				cur_history_id = max(0, cur_history_id - 1)
		elif event.pressed and event.scancode == KEY_DOWN:
			if not history.empty():
				cur_history_id = min(cur_history_id + 1, history.size() -1)
				input_box.text = history[cur_history_id]
				input_box.caret_position = input_box.text.length()
		elif event.pressed and event.scancode == KEY_TAB:
			autoComplete()


func autoComplete():
	var txt : String = input_box.text
	var keys = config.keys()
	
	var near_match = ""
	var max_char_matched = 0
	for i in keys:
		if i.length() < txt.length() or i.length() < max_char_matched:
			continue
		for c in range(txt.length()):
			if i[c] != txt[c] or c == txt.length() - 1:
				if max_char_matched < c:
					near_match = i
					max_char_matched = c
				break
		
	
	if near_match != "":
		input_box.text = near_match
		input_box.caret_position = near_match.length()

###############################################################################


func getServerInfo():
	consoleResponse("Server info -> " + String(game_server.serverInfo))


func clearOutputBox():
	output_box.text = ""


func exitConsole(code = 0):
	get_tree().quit(code)


func showHelp():
	consoleResponse("Warzone 2 Admin console.\t\t Raptor inc 2020\n")
	for i in config:
		var space = ""
		for j in range(40 - i.length()):
			space += " "
		consoleResponse("%s%s-%s" % [i, space, config[i].help])
