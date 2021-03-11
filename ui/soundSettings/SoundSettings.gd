extends TextureRect

onready var master_volume = get_node("Panel/container/master_vol") 
onready var music_volume = get_node("Panel/container/music_vol") 
onready var sfx_volume = get_node("Panel/container/sfx_vol") 
onready var ok_btn = get_node("Panel/Button") 

func _ready():
	_setValues()
	_connectSignals()


func _connectSignals():
	master_volume.connect("value_changed", self, "_on_master_volume_changed") 
	music_volume.connect("value_changed", self, "_on_music_volume_changed") 
	sfx_volume.connect("value_changed", self, "_on_sfx_volume_changed") 
	ok_btn.connect("pressed", self, "_on_ok_pressed") 


func _on_master_volume_changed(value):
	Utility.setVolumeLevel(value, "Master")
	GlobalData.settings.master_vol = value


func _on_music_volume_changed(value):
	Utility.setVolumeLevel(value, "bg_sound")
	GlobalData.settings.music_vol = value


func _on_sfx_volume_changed(value):
	Utility.setVolumeLevel(value, "weapons")
	Utility.setVolumeLevel(value, "messages")
	GlobalData.settings.sfx_vol = value


func _on_ok_pressed():
	GlobalData.saveSettings()
	UImanager.changeMenuTo("settings")


func _setValues():
	master_volume.value = GlobalData.settings.master_vol 
	sfx_volume.value = GlobalData.settings.sfx_vol 
	music_volume.value = GlobalData.settings.music_vol 
