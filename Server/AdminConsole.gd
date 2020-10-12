extends Control

onready var output_box = $input/output
onready var input_box = $input

# Function configuration
var config = {
	serverInfo = {
		ref = self, fun = "getServerInfo", is_remote = false, min_arg = 0, max_arg = 0, 
		args_types = []
	},
	
	clear = {
		ref = self, fun = "clearOutputBox", is_remote = false, min_arg = 0, max_arg = 0, 
		args_types = []
	},
	
	exit = {
		ref = self, fun = "exitConsole", is_remote = false, min_arg = 0, max_arg = 1, 
		args_types = ['i']
	},
}


# Connect Response signals
func _ready():
	Logger.console_out = true
	Logger.connect("got_new_msg", self, "consoleResponse")



# Parse input
func _on_input_text_entered(new_text : String):
	input_box.clear()
	var strings = new_text.split(" ")
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


func consoleResponse(msg):
	output_box.text += msg + "\n"


###############################################################################

func getServerInfo():
	consoleResponse("Server info -> " + String(game_server.serverInfo))


func clearOutputBox():
	output_box.text = ""


func exitConsole(code = 0):
	get_tree().quit(code)
