extends Control

var Levels_dict = {}

func _ready():
	var download = DataUploader.new()
	Levels_dict = download.getData("getLevels.php")
	var itemList = $PanelContainer/ItemList
	
	for i in Levels_dict:
		var lvl_info = Levels_dict.get(i)
		var text = "   " + lvl_info.name + " [ "
		for m in lvl_info.game_modes:
			text += m + " "
		text += "]"
		itemList.add_item(text)

