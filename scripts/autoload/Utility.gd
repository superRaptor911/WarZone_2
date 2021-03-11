extends Node

# Save Dictionary in a file
func saveDictionary(path : String, data : Dictionary) -> bool:
    var data_string = JSON.print(data)
    var file = File.new()
    var json_error = validate_json(data_string)
    # Oops invalid Dictionary
    if json_error:
        print("Error : unable to save %s" % [path])
        print("JSON IS NOT VALID FOR: " + data_string)
        print("error: " + json_error)
        return false
    # Open and save data
    var err = file.open(path,File.WRITE)
    if err != OK:
        print("Failed to open file %s" % [path])
        return false
    file.store_string(data_string)
    file.close()
    return true


# Load data from File, returns dictionary if success otherwise will return null 
func loadDictionary(path : String):
    var file : File = File.new()
    # Verify existance of file
    if not file.file_exists(path):
        print_debug('file [%s] does not exist' % path)
        return null
    # Check for any error
    var err = file.open(path,File.READ)
    if err != OK:
        print("Failed to open file %s" % [path])
        return null
        
    var json : String = file.get_as_text()
    var data = parse_json(json)
    file.close()
    return data


# Copy dictionary from source to destination dictionary
func dictionaryCpy(dest_D : Dictionary, src_D : Dictionary):
    var keys = src_D.keys()
    for i in keys:
        if dest_D.has(i):
            dest_D[i] = src_D[i]


# Check if directory exists
func dirExists(path : String):
	var dir = Directory.new()
	return dir.dir_exists(path)

# Get contetnts of a directory, modes [a = dirs and files, d= dir only, f = files only]
func scanDir(path : String , mode = 'a') -> Array:
	var list = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." && file_name != "..":
				if mode == 'a':
					list.append(file_name)
				elif mode == 'f' && !dir.current_is_dir():
					list.append(file_name)
				elif mode == 'd' && dir.current_is_dir():
					list.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list


# Funtion to get a player/unit by name (not by nick)
func getPlayer(player_name : String):
	var teams = get_tree().get_nodes_in_group("Teams")
	for i in teams:
		var plr = i.players.get(player_name)
		if plr:
			return plr.ref
	return null


# Function to set volume level (Linearly 0-3)
func setVolumeLevel(level : int, bus = "Master"):
	# Clamp level between [0 ,3]
	if level > 3:
		level = 3
	if level < 0:
		level = 0
	# Mute if level is 0
	if level == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), true)
	else:
		var db = (level - 3) * 6
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)

