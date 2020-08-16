extends Control

var tile = preload("res://Menus/Editor/Tile.tscn")
var ground_tileset : TileSet = preload("res://Sprites/Tilesets/dust_base.tres")
var wall_tileset : TileSet = preload("res://Sprites/Tilesets/dust_height.tres") 

var cur_tileset : TileSet

var tilesets = [
	{g = preload("res://Sprites/Tilesets/dust_base.tres"), w = preload("res://Sprites/Tilesets/dust_height.tres")},
	{g = preload("res://Sprites/Tilesets/ground_dark.tres"), w = preload("res://Sprites/Tilesets/height.tres")}
]

var map_size = Vector2(64,64)

enum TOOLS {PEN, AREA, RUBBER}
var current_tool = TOOLS.PEN

# Called when the node enters the scene tree for the first time.
func _ready():
	$UILayer/TileTabContainer/tileset.select(0)
	_on_tileset_item_selected(0)
	$UILayer/SettingsContainer/Options/mapName.text = game_server.serverInfo.map
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

static func delete_children(node):
	for n in node.get_children():
		n.queue_free()

# Function to load/set tileset
func setupTileset():
	cur_tileset = ground_tileset
	var tileAtalas = cur_tileset.get_tiles_ids()
	var gridContainer = $UILayer/TileTabContainer/ground/grid
	delete_children(gridContainer)
	
	for i in tileAtalas:
		var ground_texture = cur_tileset.tile_get_texture(i)
		var tex_region = cur_tileset.tile_get_region(i)
		var v_frames : int = ground_texture.get_size().y / 64
		var h_frames : int = ground_texture.get_size().x / 64
		var beg = tex_region.position / 64
		var end = tex_region.end / 64
		
		for _i in range(int(beg.y), int(end.y)):
			for _j in range(int(beg.x), int(end.x)):
				var id = h_frames * _i + _j
				var spr = tile.instance()
				spr.setData(ground_texture, v_frames, h_frames, id)
				spr.tile_id = i
				spr.auto_tile_coord = Vector2(_j - beg.x, _i  - beg.y)
				gridContainer.add_child(spr)
				spr.connect("got_selected", self, "_on_tile_selected")
	
	cur_tileset = wall_tileset
	tileAtalas = cur_tileset.get_tiles_ids()
	gridContainer = $UILayer/TileTabContainer/Walls/grid
	delete_children(gridContainer)
	
	for i in tileAtalas:
		var ground_texture = cur_tileset.tile_get_texture(i)
		var tex_region = cur_tileset.tile_get_region(i)
		var v_frames : int = ground_texture.get_size().y / 64
		var h_frames : int = ground_texture.get_size().x / 64
		var beg = tex_region.position / 64
		var end = tex_region.end / 64
		
		for _i in range(int(beg.y), int(end.y)):
			for _j in range(int(beg.x), int(end.x)):
				var id = h_frames * _i + _j
				var spr = tile.instance()
				spr.setData(ground_texture, v_frames, h_frames, id)
				spr.tile_id = i
				spr.auto_tile_coord = Vector2((_j - beg.x) , (_i - beg.y))
				spr.is_Wall = true
				gridContainer.add_child(spr)
				spr.connect("got_selected", self, "_on_tile_selected")


################################################################################

var selected_tile = null
onready var camera = $Map/Camera2D
onready var joystick = $UILayer/Joystick


func _on_tile_selected(sel_tile):
	if selected_tile:
		selected_tile.unhighlightTile()
	selected_tile = sel_tile
	selected_tile.highlightTile()


func _on_Joystick_Joystick_Updated(vector):
	camera.position += vector * 10


func _process(delta):
	camera.position += -joystick.joystick_vector * 400 * delta

var notice_shown = false

func _on_tileset_item_selected(index):
	ground_tileset = tilesets[index].g
	wall_tileset = tilesets[index].w
	setupTileset()
	if index != 0 and not notice_shown:
		Logger.notice.showNotice($UILayer, "Warning !", 
			"Changing tileset without clearing previous tiles may cause undesired effects.", 
			Color.red)
		notice_shown = true
		
	
	$Map/BaseMap.tile_set = ground_tileset
	$Map/BaseMap/height.tile_set = wall_tileset



func _on_mapName_text_changed(new_text):
	game_server.serverInfo.map = new_text


func _on_mapSize_text_entered(new_text):
	var strings = new_text.split("x")
	if strings.size() == 2:
		strings[0].erase(strings[0].length() - 1, 1)
		if strings[0].is_valid_integer() and strings[1].is_valid_integer():
			map_size = Vector2(int(strings[0]), int(strings[1]))
			$Map.update()
			return
		else:
			print(strings[0],",",strings[1])
	$UILayer/SettingsContainer/Options/mapSize.text = String(map_size.x) + "x" + String(map_size.y)


func loadMap():
	var file = File.new()
	if file.file_exists("user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn"):
		var base_map = $Map/BaseMap
		$Map.remove_child(base_map)
		base_map.queue_free()
		base_map = load("user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn").instance()
		base_map.name = "BaseMap"
		$Map.add_child(base_map)
		$Map.ground = $Map/BaseMap
		$Map.walls = $Map/BaseMap/height
		
func saveLevel():
	var packed_scene = PackedScene.new()
	var base_map = $Map/BaseMap
	$Map.remove_child(base_map)
	var result = packed_scene.pack(base_map)
	if result == OK:
		ResourceSaver.save("user://custom_maps/maps/" + game_server.serverInfo.map + ".tscn",packed_scene)
	else:
		push_error("An error occurred while saving the scene to disk.")
	

func _on_back_pressed():
	# stop the timer for safety
	$Map/minimap_update_timer.stop()
	Logger.notice.showNotice($UILayer, "Map Saved", 
			"Your Map Was Saved", 
			Color.red)
	saveLevel()
	yield(get_tree().create_timer(2), "timeout")
	MenuManager.changeScene("EMS/LevelEditorMenu")
