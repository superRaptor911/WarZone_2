extends "res://Menus/Editor/TDMspawnEditor.gd"

var zspawn = preload("res://Objects/Game_modes/ZombieMod/zombieSpawner.tscn")

func saveSpawnPoints() -> bool:
	var spawn_parent = $spawns
	var points = $editorSpawns.get_children()
	
	if points.size() == 0:
		return false
	
	var teams = [0,0]
	
	for i in points:
		if i .team_id == 0:
			var point = zspawn.instance()
			point.position = i.position
			teams[i.team_id] += 1
			spawn_parent.add_child(point)
			point.owner = spawn_parent
		else:
			var point = spawn_point.instance()
			point.position = i.position
			point.team_id = i.team_id
			teams[i.team_id] += 1
			spawn_parent.add_child(point)
			point.owner = spawn_parent
	
	if teams[0] == 0 or teams[1] == 0:
		var spawns = $spawns.get_children()
		for i in spawns:
			i.queue_free()
		return false
	
	remove_child(spawn_parent)
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(spawn_parent)
	var save_path = "user://custom_maps/gameModes/" + gameMode + "/" + game_server.serverInfo.map + ".tscn"
	if result == OK:
		ResourceSaver.save(save_path, packed_scene)
	else:
		push_error("An error occurred while saving the scene to disk.")
	spawn_parent.queue_free()
	return true
