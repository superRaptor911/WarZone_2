extends Node

var spawn_point = preload("res://Objects/Misc/spawn_point.tscn")
var editor_spawn_point = preload("res://Menus/Editor/EditorspawnPoint.tscn")

var selected_team_id = 0
var selected_spawn = null

export var gameMode = "TDM"

onready var camera = $Camera2D
onready var joystick = $uiLayer/Joystick


func _ready():
	loadMap()
	loadSpawnPoints()
	$uiLayer/ItemList.select(0)
	MenuManager.connect("back_pressed", self,"_on_back_pressed")


func _on_ItemList_item_selected(index):
	selected_team_id = index


func loadMap():
	var file = File.new()
	var file_name = "user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn"
	if file.file_exists(file_name):
		var base_map = load(file_name).instance()
		base_map.name = "BaseMap"
		base_map.force_update = false
		add_child(base_map)


func _process(delta):
	camera.position += -joystick.joystick_vector * 400 * delta


func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			var pos = event.position + camera.position
			var points = $editorSpawns.get_children()
			for i in points:
				if (i.position - pos).length() < 2 * 100:
					return
			addSpawnPoint(pos)

func addSpawnPoint(pos):
	var new_point = editor_spawn_point.instance()
	new_point.setTeamID(selected_team_id)
	new_point.position = pos
	$editorSpawns.add_child(new_point)
	new_point.connect("selected", self, "on_spawn_selected")


func on_spawn_selected(spawn):
	print("sdadsa")
	selected_spawn = spawn
	$uiLayer/spawn_option.rect_position = spawn.position - camera.position
	$uiLayer/spawn_option.show()

func loadSpawnPoints():
	var file = File.new()
	var file_name = "user://custom_maps/gameModes/" + gameMode + "/" + game_server.serverInfo.map + ".tscn"
	if file.file_exists(file_name):
		var points_node = load(file_name).instance()
		var points = points_node.get_children()
		
		for i in points:
			var p = editor_spawn_point.instance()
			p.setTeamID(i.team_id)
			p.position = i.position
			$editorSpawns.add_child(p)
			p.connect("selected", self, "on_spawn_selected")
		points_node.queue_free()


func saveSpawnPoints() -> bool:
	var spawn_parent = $spawns
	var points = $editorSpawns.get_children()
	
	if points.size() == 0:
		return false
	
	var teams = [0,0]
	
	for i in points:
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


func _on_back_pressed():
	MusicMan.click()
	if saveSpawnPoints():
		MenuManager.changeScene("EMS/LEM/GameModesMenu")
	else:
		 Logger.notice.showNotice($uiLayer, "Error", "Add atleast 1 spawn point for each team.", Color.red)


func _on_spawn_delete_pressed():
	if selected_spawn:
		selected_spawn.queue_free()
	$uiLayer/spawn_option.hide()
