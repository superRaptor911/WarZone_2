extends Node

var music_player = AudioStreamPlayer.new()
var ui_player = AudioStreamPlayer.new()

var ui_clk = preload("res://Sfx/menus/btn_hvr.wav")
var playing_index = 0

func _ready():
	loadMusic()


func loadMusic():
	add_child(music_player)
	add_child(ui_player)
	
	music_player.stream = load("res://Sfx/music/surrounded.ogg")
	ui_player.stream = ui_clk
	music_player.volume_db = -8.0
	ui_player.volume_db = 2.0
	
	if game_states.game_settings.music_enabled:
		music_player.play()


func playMusic():
	music_player.play()

func stopMusic():
	music_player.stop()

func playButtonClick():
	pass

func click():
	ui_player.play()
