extends Control

onready var ok_btn            = get_node("Panel/ok")
onready var profile_name_edit = get_node("Panel/name/LineEdit")
onready var info_label        = get_node("Panel/info")


func _ready():
	fillData()
	_connectSignals()


func _connectSignals():
	ok_btn.connect("pressed", self, "_on_ok_pressed")


func _on_ok_pressed():
	saveProfile()
	UImanager.changeMenuTo("settings")


func fillData():
	profile_name_edit.text = GlobalData.player_info.nick
	var format = "Kills : %d\nDeaths : %d"
	info_label.text = format % [GlobalData.player_info.kills, GlobalData.player_info.deaths] 


func saveProfile():
	GlobalData.player_info.nick = profile_name_edit.text
	GlobalData.savePlayerInfo()
