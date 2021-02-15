extends Control

onready var item_list : ItemList = get_node("ItemList")
onready var gen_button : Button  = get_node("Button")

const path = "res://resources/maps/"

func _ready():
	_setupItemList()
	_connectSignals()


func _connectSignals():
	gen_button.connect("pressed", self, "_on_gen_pressed")


func _loadLevelList() -> Array:
	var level_list = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.get_extension() == "tscn":
				print("Found map: " + file_name)
				level_list.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return level_list


func _setupItemList():
	var levels = _loadLevelList()
	for i in levels:
		item_list.add_item(i)


func _generateMinimap(level_name : String):
	var level_path = path + level_name
	var map = load(level_path).instance()
	var viewport = Viewport.new()
	var camera = Camera2D.new()
	add_child(viewport)
	viewport.add_child(camera)

	# Gen Minimap
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	viewport.render_target_v_flip = true
	viewport.size = (map.get_used_rect().size + map.get_used_rect().position+Vector2(1,1)) * 8
	viewport.add_child(map)
	camera.current = true
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.position = Vector2(0,0)
	camera.zoom = Vector2(1,1) * 8
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var minimap_path = path + level_name.get_basename() + ".png"
	var image = viewport.get_texture().get_data()
	image.save_png(minimap_path)
	viewport.queue_free()
	print("Generated minimap")


func _on_gen_pressed():
	var selected_items = item_list.get_selected_items()
	for i in selected_items:
		var text = item_list.get_item_text(i)
		print("generating for " + text)
		_generateMinimap(text)
