extends Control


onready var create_menu = $createMenu
onready var menu = $PanelContainer
onready var mapList = $PanelContainer/Panel/mapList

var map_dir_name = "custom_maps"



func _ready():
	UiAnim.animLeftToRight([menu])
	getMapNames()
	

func _on_create_pressed():
	UiAnim.animZoomOut([menu])
	create_menu.show()
	UiAnim.animZoomIn([create_menu])


func _on_ok_btn_pressed():
	game_server.serverInfo.map = create_menu.get_node("Panel/LineEdit").text
	MusicMan.click()
	MenuManager.changeScene("EMS/LevelEditorMenu")


func getMapNames():
	var map_dir_exist = false
	var dir = Directory.new()
	dir.open("user://")
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name == map_dir_name:
			map_dir_exist = true
			break
	
	if not map_dir_exist:
		dir.make_dir(map_dir_name)
	
	dir.open("user://" + map_dir_name)
	dir.list_dir_begin()
	file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			mapList.add_item(file_name)



func _on_mapList_item_selected(index):
	mapList.get_item_at_position(index)
