extends Control

var tile = preload("res://Menus/Editor/Tile.tscn")
var ground_tileset : TileSet = preload("res://Sprites/Tilesets/dust_base.tres")
var wall_tileset : TileSet = preload("res://Sprites/Tilesets/dust_height.tres") 

var cur_tileset : TileSet


# Called when the node enters the scene tree for the first time.
func _ready():
	setupTileset()

# Function to load/set tileset
func setupTileset():
	cur_tileset = ground_tileset
	var tileAtalas = cur_tileset.get_tiles_ids()
	var gridContainer = $UILayer/TileTabContainer/ground/grid
	
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
	camera.position += -joystick.joystick_vector * 200 * delta
