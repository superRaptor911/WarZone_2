extends Node

class_name Team

var level = null
var team_id : int = 0
var team_name : String = ""
var score : int = 0
var player_count = 0
var alive_players = 0

signal team_eliminated(team)

func _init(id,lvl):
	team_id = id
	level = lvl

func _ready():
	add_to_group("Team")
	level.connect("player_despawned",self,"removePlayer")
	level.connect("bot_despawned",self,"removePlayer")

func addPlayer(P):
	player_count += 1
	P.team = self
	P.connect("char_killed",self,"_on_player_killed")
	P.connect("char_born",self,"_on_player_born")

func removePlayer(plr):
	if plr.team.team_id == team_id:
		player_count -= 1
		if player_count == 0:
			emit_signal("team_eliminated")
		if player_count < 0:
			print("Error fatal negative number of players")


func _on_player_killed():
	alive_players -= 1
	print("player alive ",alive_players)
	if alive_players == 0:
		emit_signal("team_eliminated",self)

func _on_player_born():
	alive_players += 1
	print("player alive ",alive_players)
