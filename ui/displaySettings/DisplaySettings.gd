extends TextureRect

onready var ok_btn = get_node("Panel/ok_btn") 
onready var dynamic_cam = get_node("Panel/dynamic_cam") 
onready var gore = get_node("Panel/gore") 


func _ready():
	_connectSignals()
	_setValues()


func _connectSignals():
	dynamic_cam.connect("toggled", self, "_on_dynamic_cam_pressed") 
	gore.connect("toggled", self, "_on_gore_pressed") 
	ok_btn.connect("pressed", self, "_on_ok_pressed") 
	UImanager.connect("back_pressed", self, "_on_back_pressed") 


func _on_dynamic_cam_pressed(value : bool):
	GlobalData.settings.dynamic_cam = value


func _on_gore_pressed(value : bool):
	GlobalData.settings.gore = value


func _on_ok_pressed():
	GlobalData.saveSettings()
	UImanager.changeMenuTo("settings")


func _setValues():
	dynamic_cam.pressed = GlobalData.settings.dynamic_cam 
	gore.pressed = GlobalData.settings.gore 


func _on_back_pressed():
	UImanager.changeMenuTo("settings")
