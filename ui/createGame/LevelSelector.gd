extends Control

onready var grid_container = get_node("ScrollContainer/GridContainer") 
onready var select_btn = get_node("select_btn") 
onready var join_menu = get_parent()

var grid_item_scn = preload("res://ui/createGame/grid_item.tscn")
var levels = []
var selected_level : String = ""

signal level_selected(level_name)

func _ready():
	_connectSignals()
	loadLevels()


func _connectSignals():
	select_btn.connect("pressed", self, "_on_button_pressed")


func _on_button_pressed():
	emit_signal("level_selected", selected_level)
	queue_free()


func loadLevels():
	var level_reader = join_menu.level_reader
	levels = level_reader.getLevels()

	for i in levels:
		var texture = level_reader.getMinimap(i)
		var grid_item =	grid_item_scn.instance()
		grid_item.texture_normal = texture
		grid_item.connect("item_selected", self, "_on_level_selected")
		grid_item.name = i 
		grid_container.add_child(grid_item)


func _on_level_selected(level : String):
	if selected_level != "":
		grid_container.get_node(selected_level).unselect()
	selected_level = level
