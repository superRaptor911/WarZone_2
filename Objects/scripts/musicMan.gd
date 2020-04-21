extends Node

var music_player = AudioStreamPlayer.new()
var ui_player = AudioStreamPlayer.new()

var tracks = Array()
var ui_clk = preload("res://Sfx/menus/btn_hvr.wav")
var playing_index = 0

func _ready():
	loadMusic()


func loadMusic():
	add_child(music_player)
	add_child(ui_player)
	
	music_player.connect("finished",self,"on_music_finished")
	tracks.append(load("res://Sfx/music/XTaKeRuX_-_01_-_Free_will_possession.ogg"))
	tracks.append(load("res://Sfx/music/XTaKeRuX_-_03_-_White_Crow.ogg"))
	music_player.stream = tracks[0]
	ui_player.stream = ui_clk
	music_player.volume_db = -2.0
	ui_player.volume_db = 2.0
	
	if game_states.game_settings.music_enabled:
		playMusic()


func playMusic():
	if music_player.stream:
		print("asdds")
	music_player.play()

func stopMusic():
	music_player.stop()

func playButtonClick():
	pass

func on_music_finished():
	if game_states.game_settings.music_enabled:
		playing_index += 1
		if playing_index >= tracks.size():
			playing_index = 0
		
		music_player.stream = tracks[playing_index]
		playMusic()

func click():
	ui_player.play()
