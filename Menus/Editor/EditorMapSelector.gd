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
	var dir = Directory.new()
	dir.make_dir("user://" + map_dir_name)
	dir.make_dir("user://" + map_dir_name + "/maps")
	dir.make_dir("user://" + map_dir_name + "/gameModes")
	dir.make_dir("user://" + map_dir_name + "/minimaps")
	
	dir.open("user://" + map_dir_name + "/maps")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			mapList.add_item(file_name.get_basename())
		file_name = dir.get_next()



func _on_mapList_item_selected(index):
	game_server.serverInfo.map = mapList.get_item_text(index)
	$PanelContainer/Panel/edit.disabled = false


func _on_edit_pressed():
	MusicMan.click()
	MenuManager.changeScene("EMS/LevelEditorMenu")
