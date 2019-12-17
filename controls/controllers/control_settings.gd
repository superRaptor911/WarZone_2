extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelContainer/Panel/type.add_item("default")
	$PanelContainer/Panel/type.add_item("simple")
	if game_states.game_settings.control_type == "default":
		$PanelContainer/Panel/type.select(0)
	else:
		$PanelContainer/Panel/type.select(1)
	$PanelContainer/Panel/static_d.pressed = game_states.game_settings.static_dpad
	$PanelContainer/Panel/trans.value = game_states.game_settings.dpad_transparency
	print(game_states.game_settings.dpad_transparency)


func _on_type_item_selected(ID):
	game_states.game_settings.control_type = $PanelContainer/Panel/type.text
	


func _on_back_pressed():
	game_states.save_settings()
	get_tree().change_scene("res://Menus/Settings/Settings.tscn")


func _on_trans_value_changed(value):
	game_states.game_settings.dpad_transparency = value


func _on_static_d_toggled(button_pressed):
	game_states.game_settings.static_dpad = button_pressed
